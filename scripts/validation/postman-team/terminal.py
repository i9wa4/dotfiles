"""Adapter to the pinned Postman's actual deterministic terminal input editor."""

import hashlib
import json
import os
import pathlib
import sys

nonce, mode, prompt = sys.argv[1:]
role = os.environ["POSTMAN_SMOKE_ROLE"]
if "# Selected role: " + role not in prompt or "# Common contract" not in prompt:
    raise RuntimeError("the launcher did not supply the selected role contract")
evidence = pathlib.Path(os.environ["POSTMAN_SMOKE_EVIDENCE"])
(evidence / (role + ".bootstrap.json")).write_text(
    json.dumps(
        {
            "role": role,
            "policy_sha256": hashlib.sha256(
                prompt.split("# Common contract", 1)[1].encode()
            ).hexdigest(),
            "prompt_sha256": hashlib.sha256(prompt.encode()).hexdigest(),
            "nonce": nonce,
        }
    )
)
source = pathlib.Path(os.environ["POSTMAN_UPSTREAM_FIXTURES"]) / "terminal_agent.py"
# Reuse the immutable, pinned terminal protocol without forking its editor.
# Its sibling recipient action is the team actor below; no controller invokes it.
sys.argv = [str(pathlib.Path(__file__)), nonce, mode]
exec(  # noqa: S102 - load only the pinned test editor, with the local recipient adapter
    compile(source.read_text(), str(source), "exec"),
    {"__name__": "__main__", "__file__": __file__},
)
