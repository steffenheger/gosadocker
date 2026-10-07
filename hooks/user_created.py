#!/opt/gosa-venv/bin/python3

import subprocess

subprocess.run(
    [
        "smbpasswd",
        "-a",
        username,
    ],
    check=True,
)