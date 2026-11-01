#!/usr/bin/env python3
"""Real-tmux deterministic recursive team workflow, separate from model evals."""

import argparse
import concurrent.futures
import hashlib
import json
import os
import pathlib
import shlex
import shutil
import subprocess
import sys
import tempfile
import time
import uuid

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--postman", required=True)
parser.add_argument("--upstream-fixtures", type=pathlib.Path, required=True)
parser.add_argument(
    "--case",
    choices=["all", "root", "chain", "branch", "declined", "missing"],
    default="all",
)
parser.add_argument("--depth", type=int, default=6)
parser.add_argument(
    "--timeout", type=int, default=360, help="whole-case progress deadline"
)
parser.add_argument("--output", type=pathlib.Path)
args = parser.parse_args()
if not 4 <= args.depth <= 12:
    parser.error(
        "--depth must be between 4 and 12; this bounds fixture cost, not production trees"
    )
repo = pathlib.Path(__file__).resolve().parents[2]
launcher = repo / "scripts/bin/postman-agent"
compiler = repo / "scripts/bin/postman-team-config"
terminal = repo / "scripts/validation/postman-team/terminal.py"
template = repo / "config/tmux-a2a-postman/postman.md"
roles = ["messenger", "orchestrator", "worker", "approver", "guardian", "critic"]
postman = str(pathlib.Path(args.postman).resolve())
args.upstream_fixtures = args.upstream_fixtures.resolve()
sys.path.insert(0, str(args.upstream_fixtures))
from mail_fixture import read_archive


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def case_tree(case):
    if case in {"root", "declined"}:
        return {"team-root": None}
    if case == "missing":
        return {"team-root": None, "team-missing": "team-root"}
    depth = 4 if case == "chain" else args.depth
    parents = {"team-root": None}
    parent = "team-root"
    for level in range(1, depth):
        name = "team-a" + str(level)
        parents[name] = parent
        parent = name
    if case == "branch":
        parents.update({"team-b1": "team-root", "team-b2": "team-b1"})
    return parents


def run_case(case):
    root = pathlib.Path(tempfile.mkdtemp(prefix="pm-team-", dir="/tmp")).resolve()
    home, evidence = root / "home", root / "evidence"
    home.mkdir(mode=0o700)
    evidence.mkdir(mode=0o700)
    socket = str(root / "s")
    parents = case_tree(case)
    active = [name for name in parents if name != "team-missing"]
    config, tree_file = root / "postman.md", root / "tree.json"
    tree_file.write_text(
        json.dumps(
            {
                "sessions": [
                    {"name": name, "parent": parent} for name, parent in parents.items()
                ]
            }
        )
    )
    env = {
        **os.environ,
        "HOME": str(home),
        "ZDOTDIR": str(home),
        "XDG_CONFIG_HOME": str(home / "config"),
        "XDG_DATA_HOME": str(home / "data"),
        "XDG_CACHE_HOME": str(home / "cache"),
        "XDG_STATE_HOME": str(root / "state"),
        "BASH_ENV": "",
        "ENV": "",
        "HISTFILE": str(home / "history"),
        "INPUTRC": str(home / "inputrc"),
        "SHELL": shutil.which("bash"),
        "GIT_CONFIG_GLOBAL": os.devnull,
        "GIT_CONFIG_NOSYSTEM": "1",
        "POSTMAN_BIN": postman,
        "POSTMAN_CONFIG": str(config),
        "POSTMAN_TEAM_CONFIG": str(config),
        "POSTMAN_UPSTREAM_FIXTURES": str(args.upstream_fixtures),
        "LOGBOOK_SKILL_ROOT": str(repo / "skills/logbook"),
        "MKMD_BASE_DIR": str(evidence / "logbook"),
        "POSTMAN_SMOKE_CASE": "recursive-team",
        "POSTMAN_TEAM_APPROVAL": "rejected" if case == "declined" else "approved",
    }
    env.pop("TMUX", None)
    env.pop("TMUX_PANE", None)
    panes, commands, nonces, roots = {}, {}, {}, {}
    report = {
        "case": case,
        "result": "failed",
        "root": str(root),
        "parents": parents,
        "actors": "fixed deterministic decisions in real terminal editors",
        "human_trial": False,
    }

    def tmux(*values):
        return subprocess.check_output(
            ["tmux", "-S", socket, *values], env=env, text=True, timeout=5
        ).strip()

    deadline = time.monotonic() + args.timeout

    def wait_for(label, condition):
        while not condition():
            errors = list(evidence.glob("*/*.error.txt"))
            if errors:
                raise RuntimeError(errors[0].read_text())
            if time.monotonic() >= deadline:
                raise RuntimeError("timed out: " + label)
            time.sleep(0.05)

    def caller_env(session, role):
        return {**env, "TMUX": socket + ",0,0", "TMUX_PANE": panes[(session, role)]}

    def send_initial(root_id, goal):
        body = {
            "kind": "task",
            "root_id": root_id,
            "goal": goal,
            "goal_sha256": digest(goal),
        }
        result = subprocess.run(
            [postman, "send-heredoc", "--config", str(config), "--to", "orchestrator"],
            check=False,
            input=json.dumps(body),
            text=True,
            capture_output=True,
            env=caller_env("team-root", "messenger"),
            cwd=roots["team-root"],
            timeout=20,
        )
        output = json.loads(result.stdout)
        if result.returncode or not output["success"]:
            raise RuntimeError(
                "root initial send failed: " + result.stdout + result.stderr
            )
        matches = []
        for path in (root / "state").glob(
            "tmux-a2a-postman/*/agents/messenger/sent/*.md"
        ):
            msg = read_archive(path)
            try:
                value = json.loads(msg["body"])
            except ValueError:
                continue
            if value == body:
                matches.append(msg)
        if len(matches) != 1:
            raise RuntimeError("initial request lost its exact identity")
        return matches[0]

    def outcomes():
        path = evidence / "team-root/messenger.state.json"
        return json.loads(path.read_text()).get("outcomes", {}) if path.exists() else {}

    def scope_indexes():
        result = {}
        for session in active:
            path = evidence / session / "orchestrator.state.json"
            if path.exists():
                item = json.loads(path.read_text())
                if item.get("index"):
                    result[session] = item["index"]
        return result

    def actors_finished():
        for path in evidence.glob("*/*.input.jsonl"):
            actions = path.with_name(
                path.name.replace(".input.jsonl", ".actions.jsonl")
            )
            if not actions.exists() or len(actions.read_text().splitlines()) != len(
                path.read_text().splitlines()
            ):
                return False
        return True

    def verify_flow(root_id, goal, request):
        outcome = outcomes()[root_id]
        body, msg = outcome["body"], outcome["message"]
        expected = "blocked" if case in {"declined", "missing"} else "done"
        if (
            body["status"] != expected
            or body["goal"] != goal
            or body["goal_sha256"] != digest(goal)
        ):
            raise RuntimeError("false completion or original goal changed")
        if not any(
            ref["message_id"] == request["id"] for ref in msg.get("replies", [])
        ):
            raise RuntimeError("root result answered another parallel request")
        for session, index in scope_indexes().items():
            data = pathlib.Path(index).read_text()
            task = json.loads(data.split("```json\n", 1)[1].split("\n```", 1)[0])[
                "tasks"
            ][root_id]
            if (
                task["goal"] != goal
                or task["goal_sha256"] != digest(goal)
                or task["status"] != expected
            ):
                raise RuntimeError(
                    "child scope lost its original task or returned false DONE: "
                    + session
                )
        markers = list(home.glob("scopes/*/executed-" + root_id))
        if expected == "done" and (
            not markers or any(path.read_text() != "once" for path in markers)
        ):
            raise RuntimeError("leaf work did not execute exactly once")
        if expected == "blocked" and markers:
            raise RuntimeError("a refused/missing task executed")
        return {
            "root_id": root_id,
            "request_id": request["id"],
            "result_id": msg["id"],
            "status": body["status"],
            "goal_sha256": digest(goal),
            "markers": len(markers),
        }

    try:
        subprocess.run(
            [
                sys.executable,
                str(compiler),
                "--template",
                str(template),
                "--tree",
                str(tree_file),
                "--output",
                str(config),
            ],
            check=True,
            env=env,
            capture_output=True,
        )
        for session in active:
            work = home / "scopes" / session
            work.mkdir(parents=True)
            roots[session] = work
            subprocess.run(
                ["git", "init", "-q", "-b", "fixture"], cwd=work, env=env, check=True
            )
            subprocess.run(
                [
                    "git",
                    "-c",
                    "core.hooksPath=/dev/null",
                    "-c",
                    "user.name=fixture",
                    "-c",
                    "user.email=fixture@example.invalid",
                    "-c",
                    "commit.gpgsign=false",
                    "commit",
                    "-q",
                    "--allow-empty",
                    "-m",
                    "fixture",
                ],
                cwd=work,
                env=env,
                check=True,
            )
            role_evidence = evidence / session
            role_evidence.mkdir()
            for index, role in enumerate(roles):
                nonce = uuid.uuid4().hex
                nonces[(session, role)] = nonce
                extra = {
                    "POSTMAN_TEAM_SESSION": session,
                    "POSTMAN_SMOKE_ROLE": role,
                    "POSTMAN_SMOKE_EVIDENCE": str(role_evidence),
                    "POSTMAN_SMOKE_CONVERSATION": uuid.uuid4().hex,
                }
                cmd = [
                    "env",
                    *(key + "=" + value for key, value in extra.items()),
                    sys.executable,
                    str(launcher),
                    "--config",
                    str(config),
                    role,
                    "--",
                    sys.executable,
                    str(terminal),
                    nonce,
                    "plain" if case == "root" else "bracketed",
                    "@postman-prompt",
                ]
                command = "exec " + shlex.join(cmd)
                commands[(session, role)] = command
                if index == 0:
                    pane = tmux(
                        "-f",
                        "/dev/null",
                        "new-session",
                        "-d",
                        "-s",
                        session,
                        "-c",
                        str(work),
                        "-P",
                        "-F",
                        "#{pane_id}",
                        command,
                    )
                    tmux("set-option", "-t", session, "default-shell", env["SHELL"])
                else:
                    pane = tmux(
                        "new-window",
                        "-d",
                        "-t",
                        session,
                        "-c",
                        str(work),
                        "-P",
                        "-F",
                        "#{pane_id}",
                        command,
                    )
                panes[(session, role)] = pane
                tmux("resize-window", "-t", pane, "-x", "240", "-y", "60")
                wait_for(
                    "role bootstrap " + session + "/" + role,
                    lambda p=role_evidence / (role + ".ready.json"): p.exists(),
                )

        # Initial negative sends exercise the actual parser/route admission.
        # The controller never supplies a recipient POP, read, reply or decision.
        probes = [("team-root", "worker", "critic")]
        if len(active) > 2:
            probes += [("team-root", "messenger", active[2] + ":messenger")]
        if "team-b1" in active:
            probes += [("team-a1", "messenger", "team-b1:messenger")]
        report["route_probes"] = []
        for session, role, target in probes:
            result = subprocess.run(
                [postman, "send-heredoc", "--config", str(config), "--to", target],
                check=False,
                input="must be denied",
                env=caller_env(session, role),
                cwd=roots[session],
                capture_output=True,
                text=True,
                timeout=20,
            )
            output = json.loads(result.stdout)
            if result.returncode == 0 or output["success"]:
                raise RuntimeError("unauthorized local/non-adjacent route was accepted")
            report["route_probes"].append(
                {
                    "session": session,
                    "role": role,
                    "to": target,
                    "reason": output.get("reason"),
                }
            )

        count = 2 if case == "branch" else 1
        goals = {
            uuid.uuid4().hex: {
                "objective": "Preserve this original goal through each owned team scope",
                "case": case,
                "constraints": [
                    "no production writes",
                    "no model APIs",
                    "exact request/reply correlation",
                ],
                "acceptance": [
                    "leaf command decided by local approver",
                    "guardian/critic route",
                    "child evidence retained",
                ],
            }
            for _ in range(count)
        }
        with concurrent.futures.ThreadPoolExecutor(max_workers=count) as pool:
            requests = dict(
                zip(goals, pool.map(lambda item: send_initial(*item), goals.items()))
            )
        wait_for(
            "root outcomes", lambda: all(root_id in outcomes() for root_id in goals)
        )
        report["flows"] = [
            verify_flow(root_id, goal, requests[root_id])
            for root_id, goal in goals.items()
        ]
        indexes_before = scope_indexes()

        if case == "chain":
            # Respawn a completed child scope with the same durable mail/index.
            leaf = active[-1]
            for role in ["messenger", "orchestrator", "worker"]:
                ready = evidence / leaf / (role + ".ready.json")
                ready.unlink()
                tmux(
                    "respawn-pane",
                    "-k",
                    "-t",
                    panes[(leaf, role)],
                    "-c",
                    str(roots[leaf]),
                    commands[(leaf, role)],
                )
                wait_for("restarted role", lambda p=ready: p.exists())
            root_id = uuid.uuid4().hex
            goal = {
                "objective": "Fresh work after restart must ignore an old exact reply",
                "inject_late": True,
                "constraints": ["reuse the canonical index", "no command replay"],
            }
            request = send_initial(root_id, goal)
            wait_for("fresh post-restart outcome", lambda: root_id in outcomes())
            report["flows"].append(verify_flow(root_id, goal, request))
            if scope_indexes() != indexes_before:
                raise RuntimeError("restart replaced a canonical index")
            worker_state = json.loads(
                (evidence / leaf / "worker.state.json").read_text()
            )
            if not worker_state.get("late_replies"):
                raise RuntimeError("late-response control was not exercised")
            report["restart_reused_indexes"] = True

        policies = {}
        claims = []
        wait_for("all submitted terminal actions completed", actors_finished)
        for path in evidence.glob("*/*.bootstrap.json"):
            value = json.loads(path.read_text())
            policies.setdefault(value["role"], set()).add(value["policy_sha256"])
        if any(len(values) != 1 for values in policies.values()):
            raise RuntimeError("role prompt changed with depth")
        for path in evidence.glob("*/*.claim.*.json"):
            proof = json.loads(path.read_text())
            if (
                hashlib.sha256(pathlib.Path(proof["archive"]).read_bytes()).hexdigest()
                != proof["sha256"]
            ):
                raise RuntimeError("full archived body was not retained")
            claims.append(
                {
                    "session": proof["session"],
                    "role": proof["role"],
                    "id": proof["message"]["id"],
                    "sha256": proof["sha256"],
                }
            )
        report.update(
            result="pass",
            claimed_full_archives=claims,
            scope_indexes=indexes_before,
            max_depth=max(sum(1 for _ in ancestors(name, parents)) for name in parents),
            role_policy_equal_across_depth=True,
            false_completions=0,
        )
    except Exception as error:  # noqa: BLE001 - retain failure evidence before private-server teardown
        report["error"] = str(error)
    finally:
        if report["result"] != "pass":
            report["errors"] = {
                str(p.relative_to(evidence)): p.read_text()
                for p in evidence.glob("*/*.error.txt")
            }
            report["screens"] = {}
            for key, pane in panes.items():
                try:
                    report["screens"]["/".join(key)] = tmux(
                        "capture-pane", "-p", "-t", pane
                    )[-2500:]
                except subprocess.SubprocessError:
                    pass
        subprocess.run(
            ["tmux", "-S", socket, "kill-server"],
            check=False,
            env=env,
            capture_output=True,
            timeout=5,
        )
        (root / "report.json").write_text(json.dumps(report, indent=2))
    print(
        json.dumps(
            {
                "case": case,
                "result": report["result"],
                "error": report.get("error"),
                "report": str(root / "report.json"),
            }
        ),
        flush=True,
    )
    return report


def ancestors(name, parents):
    while name is not None:
        yield name
        name = parents[name]


cases = (
    ["root", "chain", "branch", "declined", "missing"]
    if args.case == "all"
    else [args.case]
)
reports = []
for case in cases:
    reports.append(run_case(case))
    if reports[-1]["result"] != "pass":
        break
result = {
    "result": "pass" if all(r["result"] == "pass" for r in reports) else "failed",
    "cases": reports,
}
if args.output:
    args.output.write_text(json.dumps(result, indent=2))
raise SystemExit(0 if result["result"] == "pass" else 1)
