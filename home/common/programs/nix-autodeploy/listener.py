"""Forge webhook listener that turns a push into a flake-input bump.

Verifies the HMAC a Gitea (or GitHub) webhook signs the body with, then hands
the actual work to a transient systemd unit. Nothing is done in-process: the
deploy runs `nh home switch`, which restarts every unit home-manager owns —
including this listener — so the job has to outlive it.
"""

import hashlib
import hmac
import json
import os
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SECRET = os.environ.get("NIX_AUTODEPLOY_SECRET", "").encode()
PORT = int(os.environ.get("NIX_AUTODEPLOY_PORT", "7375"))
DEPLOY = os.environ["NIX_AUTODEPLOY_DEPLOY_BIN"]
# {"<owner>/<repo>": {"input": "rev", "apply": true}, ...}
REPOS = json.loads(os.environ["NIX_AUTODEPLOY_REPOS"])
ENV_FILE = os.environ.get("NIX_AUTODEPLOY_ENV_FILE", "")
MAX_BODY = 1 << 20

if not SECRET:
    sys.exit("NIX_AUTODEPLOY_SECRET is not set")


def signature_ok(body: bytes, headers) -> bool:
    expected = hmac.new(SECRET, body, hashlib.sha256).hexdigest()
    # Gitea sends the bare hex digest; GitHub prefixes it with "sha256=".
    for name in ("X-Gitea-Signature", "X-Hub-Signature-256"):
        got = headers.get(name)
        if got and hmac.compare_digest(got.removeprefix("sha256="), expected):
            return True
    return False


def spawn(repo: str, entry: dict) -> None:
    cmd = [
        "systemd-run",
        "--user",
        "--collect",
        f"--description=nix-autodeploy: {repo}",
        # PATH is not inherited by a transient unit, and the deploy shells out
        # to git, nix and the gitea credential helper.
        f"--setenv=PATH={os.environ['PATH']}",
    ]
    if ENV_FILE:
        cmd.append(f"--property=EnvironmentFile={ENV_FILE}")
    cmd += [DEPLOY, entry["input"], "apply" if entry.get("apply", True) else "notify"]
    subprocess.run(cmd, check=True)


class Handler(BaseHTTPRequestHandler):
    def reply(self, code: int, text: str) -> None:
        payload = text.encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler's spelling
        if self.path == "/health":
            self.reply(200, "ok\n")
        else:
            self.reply(404, "no\n")

    def do_POST(self) -> None:  # noqa: N802
        length = int(self.headers.get("Content-Length", "0"))
        if length > MAX_BODY:
            return self.reply(413, "body too large\n")
        body = self.rfile.read(length)

        if not signature_ok(body, self.headers):
            return self.reply(401, "bad signature\n")

        try:
            event = json.loads(body)
        except json.JSONDecodeError:
            return self.reply(400, "bad json\n")

        ref = event.get("ref")
        repo = (event.get("repository") or {}).get("full_name")
        if ref != "refs/heads/main":
            return self.reply(200, f"ignored ref {ref}\n")

        entry = REPOS.get(repo)
        if entry is None:
            return self.reply(200, f"ignored repo {repo}\n")

        spawn(repo, entry)
        self.reply(202, f"deploying {entry['input']}\n")

    def log_message(self, fmt: str, *args) -> None:
        # Journal already timestamps; the default format prepends its own.
        sys.stderr.write(f"{self.address_string()} {fmt % args}\n")


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
