"""Fixed team decisions triggered exclusively by submitted terminal input."""

import hashlib
import json
import os
import pathlib
import re
import runpy
import shlex
import subprocess
import sys
import tempfile
import uuid

sys.path.insert(0, os.environ["POSTMAN_UPSTREAM_FIXTURES"])
from mail_fixture import read_archive

phase, nonce = sys.argv[1:]
role = os.environ["POSTMAN_SMOKE_ROLE"]
session = os.environ["POSTMAN_TEAM_SESSION"]
evidence = pathlib.Path(os.environ["POSTMAN_SMOKE_EVIDENCE"])
work = pathlib.Path.cwd().resolve()
config = os.environ["POSTMAN_CONFIG"]
postman = os.environ["POSTMAN_BIN"]
state_path = evidence / (role + ".state.json")
state = (
    json.loads(state_path.read_text())
    if state_path.exists()
    else {"waiting": {}, "tasks": {}, "work": {}}
)


class DeliveryError(RuntimeError):
    pass


def atomic(path, text):
    path = pathlib.Path(path)
    with tempfile.NamedTemporaryFile(dir=path.parent, mode="w", delete=False) as target:
        target.write(text)
        temp = pathlib.Path(target.name)
    temp.replace(path)


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def save():
    atomic(state_path, json.dumps(state, indent=2))
    if role == "orchestrator" and state.get("index"):
        index = pathlib.Path(state["index"])
        if not index.exists():
            raise RuntimeError("canonical scope index disappeared; no replacement")
        original = index.read_text()
        if state["scope_identity"] not in original:
            raise RuntimeError("canonical scope index identity changed")
        atomic(
            index,
            "# Team scope index\n\n"
            + state["scope_identity"]
            + "\n\n```json\n"
            + json.dumps({"tasks": state["tasks"]}, indent=2)
            + "\n```\n",
        )


def cli(args, body=None, allow_failure=False):
    result = subprocess.run(
        [postman, *args, "--config", config],
        check=False,
        input=body,
        capture_output=True,
        text=True,
        timeout=40,
    )
    output = json.loads(result.stdout)
    failed = result.returncode or (
        args[0] != "get-status" and not output.get("success")
    )
    if not allow_failure and failed:
        raise RuntimeError("mail operation failed: " + result.stdout + result.stderr)
    return output


def own_sent(wire_nonce):
    files = pathlib.Path(os.environ["XDG_STATE_HOME"]).glob(
        "tmux-a2a-postman/*/agents/" + role + "/sent/*.md"
    )
    found = []
    for path in files:
        msg = read_archive(path)
        try:
            body = json.loads(msg["body"])
        except ValueError:
            continue
        if body.get("wire_nonce") == wire_nonce:
            found.append(msg)
    if len(found) != 1:
        raise RuntimeError("cannot identify one exact own sent message")
    return found[0]


def send(to, payload, waiting=None):
    payload = {**payload, "wire_nonce": uuid.uuid4().hex}
    output = cli(["send-heredoc", "--to", to], json.dumps(payload), allow_failure=True)
    if not output["success"]:
        raise DeliveryError("send failed: " + json.dumps(output))
    msg = own_sent(payload["wire_nonce"])
    if waiting is not None:
        state["waiting"][msg["id"]] = waiting
        save()
    # Supplemental notification uncertainty never reverses committed mail.
    # Actual terminal input, full reads and exact end-to-end replies are proved
    # independently by the controller; there is no recipient polling fallback.
    return msg


def answer(request, payload):
    return send(request, payload)


def packet(task, kind, **fields):
    return {
        "kind": kind,
        "root_id": task["root_id"],
        "goal": task["goal"],
        "goal_sha256": task["goal_sha256"],
        **fields,
    }


def require_goal(body):
    if not re.fullmatch(r"[a-f0-9]{32}", body.get("root_id", "")) or digest(
        body.get("goal")
    ) != body.get("goal_sha256"):
        raise RuntimeError("original goal identity/digest changed")


def index_for_scope():
    branch = subprocess.check_output(
        ["git", "branch", "--show-current"], text=True
    ).strip()
    identity = "Scope: " + json.dumps(
        {"repo": str(work), "branch": branch, "owner": role}, sort_keys=True
    )
    if state.get("index"):
        if (
            state.get("scope_identity") != identity
            or not pathlib.Path(state["index"]).exists()
        ):
            raise RuntimeError("scope mismatch; do not silently replace canonical SSOT")
        return
    script = pathlib.Path(os.environ["LOGBOOK_SKILL_ROOT"]) / "scripts/mkmd"
    path = subprocess.check_output(
        ["bash", str(script), "--dir", "orchestration", "--label", "team-scope"],
        text=True,
    ).splitlines()[0]
    state["index"], state["scope_identity"] = path, identity
    pathlib.Path(path).write_text("# Team scope index\n\n" + identity + "\n")
    save()


def finish_task(task):
    task["status"] = (
        "done"
        if task.get("reviewed")
        and all(child["status"] == "done" for child in task["children"].values())
        else "blocked"
    )
    save()
    answer(
        task["request_id"],
        packet(
            task,
            "result",
            status=task["status"],
            artifact=state["index"],
            scope=session,
            children=task["children"],
            checklist="PASS" if task["status"] == "done" else "FAIL",
        ),
    )


def maybe_review(task):
    if any(item["status"] == "waiting" for item in task["children"].values()):
        return
    if any(item["status"] != "done" for item in task["children"].values()):
        finish_task(task)
        return
    task["status"] = "reviewing"
    save()
    send(
        "guardian",
        packet(task, "review", artifact=state["index"]),
        {"stage": "review", "root_id": task["root_id"]},
    )


def start_children(task, scope):
    task["scope"] = scope
    children = [row["session"] for row in scope["children"]]
    if not children:
        task["children"]["local-worker"] = {"status": "waiting"}
        send(
            "worker",
            packet(task, "work"),
            {"stage": "child", "root_id": task["root_id"], "child": "local-worker"},
        )
    else:
        for child in children:
            task["children"][child] = {"status": "waiting"}
            send(
                "messenger",
                packet(task, "relay", target=child, payload=packet(task, "task")),
                {"stage": "child", "root_id": task["root_id"], "child": child},
            )
    save()


def worker_run(task):
    task["phase"] = "executing"
    save()  # A restart at this boundary must not silently repeat the command.
    marker = work / ("executed-" + task["root_id"])
    source = "printf once >> " + shlex.quote(str(marker))
    result = subprocess.run(
        [
            postman,
            "execute-heredoc",
            "--config",
            config,
            "--reason",
            "fixture " + task["root_id"],
        ],
        check=False,
        input=source,
        text=True,
        capture_output=True,
        timeout=40,
    )
    output = json.loads(result.stderr.splitlines()[-1])
    expected = os.environ["POSTMAN_TEAM_APPROVAL"]
    if output.get("approval", {}).get("decision") != expected:
        raise RuntimeError("exact local approver was not used")
    good = output["executed"] is True and output["success"] and result.returncode == 0
    if good and marker.read_text() != "once":
        raise RuntimeError("execution ran more than once")
    if not good and (marker.exists() or output["executed"] is not False):
        raise RuntimeError("refused execution had an unknown/started outcome")
    script = pathlib.Path(os.environ["LOGBOOK_SKILL_ROOT"]) / "scripts/mkmd"
    artifact = subprocess.check_output(
        ["bash", str(script), "--dir", "reviews", "--label", "work-evidence"], text=True
    ).splitlines()[0]
    pathlib.Path(artifact).write_text(
        "# Work evidence\n\n```json\n"
        + json.dumps(
            {
                "root_id": task["root_id"],
                "goal": task["goal"],
                "goal_sha256": task["goal_sha256"],
                "execution": output,
                "checklist": "PASS" if good else "FAIL",
                "owner": role,
                "scope": session,
            },
            indent=2,
        )
        + "\n```\n"
    )
    task["phase"] = "done" if good else "blocked"
    task["artifact"] = artifact
    save()
    answer(
        task["request_id"],
        packet(task, "result", status=task["phase"], artifact=artifact, scope=session),
    )


def handle(msg, body):
    require_goal(body)
    root_id = body["root_id"]
    refs = [ref["message_id"] for ref in msg.get("replies", [])]
    if not msg["needs_reply"]:
        matches = [ref for ref in refs if ref in state["waiting"]]
        if not matches:
            # An old exact reply is history, never a fresh task/authorization.
            if role == "messenger" and body["kind"] == "result":
                scope = cli(["get-status"])
                if scope.get("parent") is None:
                    state.setdefault("outcomes", {})[root_id] = {
                        "message": msg,
                        "body": body,
                    }
                    save()
            return
        if len(matches) != 1:
            raise RuntimeError("ambiguous pending handoff")
        pending = state["waiting"].pop(matches[0])
        if pending["root_id"] != root_id:
            raise RuntimeError("parallel request/root correlation crossed")
        stage = pending["stage"]
        if stage == "forward":
            answer(pending["request_id"], body)
        elif stage == "scope":
            start_children(state["tasks"][root_id], body["scope"])
        elif stage == "child":
            task = state["tasks"][root_id]
            task["children"][pending["child"]] = {
                "status": body["status"],
                "artifact": body.get("artifact"),
                "request_id": matches[0],
                "reply_id": msg["id"],
            }
            save()
            maybe_review(task)
        elif stage == "review":
            task = state["tasks"][root_id]
            task["reviewed"] = body.get("verdict") == "approved"
            finish_task(task)
        elif stage == "guardian":
            answer(pending["request_id"], body)
        elif stage == "question":
            if body.get("decision") is not True:
                raise RuntimeError("unexpected scoped decision")
            worker_run(state["work"][root_id])
        save()
        return
    if role == "messenger":
        if body["kind"] == "scope-query":
            status = cli(["get-status"])
            answer(
                msg["id"],
                packet(
                    body,
                    "scope",
                    scope={
                        "parent": status.get("parent"),
                        "children": status.get("children", []),
                    },
                ),
            )
        elif body["kind"] == "relay":
            try:
                send(
                    body["target"] + ":messenger",
                    body["payload"],
                    {"stage": "forward", "root_id": root_id, "request_id": msg["id"]},
                )
            except DeliveryError as error:
                answer(
                    msg["id"],
                    packet(
                        body,
                        "result",
                        status="blocked",
                        reason=str(error),
                        artifact=None,
                    ),
                )
        else:
            send(
                "orchestrator",
                body,
                {"stage": "forward", "root_id": root_id, "request_id": msg["id"]},
            )
    elif role == "orchestrator":
        if body["kind"] == "task":
            index_for_scope()
            if root_id in state["tasks"]:
                raise RuntimeError("task replay attempted")
            task = {
                **body,
                "request_id": msg["id"],
                "status": "working",
                "children": {},
                "reviewed": False,
            }
            state["tasks"][root_id] = task
            save()
            send(
                "messenger",
                packet(task, "scope-query"),
                {"stage": "scope", "root_id": root_id},
            )
        elif body["kind"] == "question":
            task = state["tasks"][root_id]
            parent = task["scope"].get("parent")
            if parent:
                send(
                    "messenger",
                    packet(task, "relay", target=parent["session"], payload=body),
                    {"stage": "forward", "root_id": root_id, "request_id": msg["id"]},
                )
            else:
                answer(msg["id"], packet(task, "decision", decision=True))
    elif role == "worker" and body["kind"] == "work":
        if root_id in state["work"]:
            raise RuntimeError("a possibly executed source cannot be replayed")
        if body["goal"].get("inject_late"):
            old = next(
                (
                    item
                    for item in state["work"].values()
                    if item.get("phase") == "done"
                ),
                None,
            )
            if old:
                answer(
                    old["request_id"],
                    packet(
                        old,
                        "result",
                        status="done",
                        artifact=old["artifact"],
                        late_fixture=True,
                    ),
                )
                state.setdefault("late_replies", []).append(old["root_id"])
        state["work"][root_id] = {**body, "request_id": msg["id"], "phase": "question"}
        save()
        send(
            "orchestrator",
            packet(
                body,
                "question",
                question="Confirm this original scope before execution",
            ),
            {"stage": "question", "root_id": root_id},
        )
    elif role == "guardian" and body["kind"] == "review":
        send(
            "critic",
            packet(body, "review", artifact=body["artifact"]),
            {"stage": "guardian", "root_id": root_id, "request_id": msg["id"]},
        )
    elif role == "critic" and body["kind"] == "review":
        path = pathlib.Path(body["artifact"])
        full = path.read_text()
        data = json.loads(full.split("```json\n", 1)[1].split("\n```", 1)[0])
        task = data["tasks"][root_id]
        good = (
            task["goal"] == body["goal"]
            and task["goal_sha256"] == body["goal_sha256"]
            and all(
                item["status"] == "done" and pathlib.Path(item["artifact"]).exists()
                for item in task["children"].values()
            )
        )
        answer(
            msg["id"],
            packet(
                body,
                "verdict",
                verdict="approved" if good else "rejected",
                simulated_review=True,
                evidence_sha256=hashlib.sha256(full.encode()).hexdigest(),
            ),
        )
    else:
        raise RuntimeError("unsupported authored role/action")


def receive():
    output = cli(["pop"])
    if output["markdown_absolute_path"] is None:
        return 0
    if "through EOF" not in output.get("instruction", ""):
        raise RuntimeError(
            "recipient parity requires the full-read POP instruction (upstream #960)"
        )
    archive = pathlib.Path(output["markdown_absolute_path"])
    raw = archive.read_bytes()
    msg = read_archive(archive)
    context = msg.get("recipient_context", "")
    required = [
        "## Recipient Instructions",
        "### Available Skills",
        "You can talk to:",
        "## Sender Message",
        "Read this complete archived Markdown through EOF",
    ]
    if any(part not in context for part in required):
        raise RuntimeError(
            "received archive omitted historical recipient policy/catalog/contact guidance"
        )
    loader = pathlib.Path(__file__).resolve().parents[3] / "scripts/bin/postman-agent"
    sections = runpy.run_path(str(loader))["role_sections"](pathlib.Path(config))
    if any(sections[name] not in context for name in ["common_template", role]):
        raise RuntimeError(
            "received archive truncated or substituted full common/selected-role instructions"
        )
    if msg["to"] != role or (msg.get("to_session") and msg["to_session"] != session):
        raise RuntimeError("archive belongs to another recipient")
    proof = {
        "role": role,
        "session": session,
        "nonce": nonce,
        "archive": str(archive),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "pop_instruction": output["instruction"],
        "recipient_context_sha256": hashlib.sha256(context.encode()).hexdigest(),
        "message": msg,
    }
    if role == "approver" and msg.get("kind") == "execution-request":
        request = json.loads(msg["body"])
        if (
            request.get("version") != 2
            or request["cwd"] != str(work)
            or not request["reason"].startswith("fixture ")
        ):
            raise RuntimeError("execution conditions changed")
        root_id = request["reason"][8:]
        expected = "printf once >> " + shlex.quote(str(work / ("executed-" + root_id)))
        if request["command"] != expected:
            raise RuntimeError("approver was asked to run different source")
        action = (
            "approve-execution"
            if os.environ["POSTMAN_TEAM_APPROVAL"] == "approved"
            else "decline-execution"
        )
        proof["decision"] = cli(
            [action, "--to", msg["id"], "--reason", "fixed fixture decision"]
        )
    else:
        handle(msg, json.loads(msg["body"]))
    atomic(evidence / (role + ".claim." + msg["id"] + ".json"), json.dumps(proof))
    save()
    # Read current own file facts after all nested sends/claims. Unknown stops
    # the finite batch; it never starts idle polling.
    status = cli(["get-status"])
    own = next(row for row in status["nodes"] if row["node"] == role)
    return own.get("unread_count") or 0


try:
    if phase == "setup":
        (evidence / (role + ".ready.json")).write_text(
            json.dumps({"role": role, "nonce": nonce})
        )
        print("TEAM_READY", session, role)
    else:
        remaining = 1
        for _ in range(64):
            if remaining <= 0:
                break
            remaining = receive()
        if remaining:
            raise RuntimeError("finite known-mail batch exceeded its bound")
        with (evidence / (role + ".actions.jsonl")).open("a") as trace:
            trace.write(json.dumps({"hint": phase, "nonce": nonce}) + "\n")
except Exception as error:
    (evidence / (role + ".error.txt")).write_text(str(error))
    raise
