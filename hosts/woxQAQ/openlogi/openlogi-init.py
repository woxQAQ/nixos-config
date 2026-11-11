"""Exercise the initializer process and mutable config lifecycle without HID access.

Usage: python tests/openlogi-init.py /path/to/openlogi-init
"""

import subprocess
import sys
import tempfile
from pathlib import Path

import tomllib

if len(sys.argv) != 2:
    raise SystemExit(__doc__)

binary = Path(sys.argv[1]).resolve()
key = "receiver:integration-fixture:slot:1"
actions = {
    "Up": "focus-workspace-up",
    "Down": "focus-workspace-down",
    "Left": "focus-column-left",
    "Right": "focus-column-right",
    "Click": "toggle-overview",
}
# Keep the fixture independent of the writable profile, which the GUI edits.
seed = (
    "\n".join(
        [
            "schema_version = 3",
            'selected_device = "niri"',
            "[devices.niri]",
            "dpi = 1000",
            "[devices.niri.bindings.GestureButton]",
            *[
                f'{direction} = {{ RunShellCommand = "/run/current-system/sw/bin/niri msg action {action}" }}'
                for direction, action in actions.items()
            ],
        ]
    )
    + "\n"
)

with tempfile.TemporaryDirectory(prefix="openlogi-niri-") as root:
    root = Path(root)
    tracked = root / "tracked.toml"
    tracked.write_text(seed)
    linked = root / "config.toml"
    linked.symlink_to(tracked)
    subprocess.run([binary, linked, "--device-key", key], check=True)
    assert linked.is_symlink(), "saving must preserve the mutable config link"
    config = tomllib.loads(tracked.read_text())
    assert config["selected_device"] == key
    assert set(config["devices"]) == {key}
    assert config["devices"][key] == tomllib.loads(seed)["devices"]["niri"]
    tracked.write_text(tracked.read_text().replace("dpi = 1000", "dpi = 1400"))
    before = tracked.read_bytes()
    subprocess.run([binary, linked], check=True)
    assert linked.is_symlink()
    assert tracked.read_bytes() == before, (
        "restarts must preserve GUI edits without HID probes"
    )
    bad = root / "invalid.toml"
    bad.write_text(seed)
    result = subprocess.run(
        [binary, bad, "--device-key", "not-a-device"], capture_output=True, check=False
    )
    assert result.returncode != 0
    assert bad.read_text() == seed, "invalid identity must not alter the config"
    result = subprocess.run(
        [binary, root / "missing.toml"], capture_output=True, check=False
    )
    assert result.returncode != 0, (
        "missing config must not silently skip initialization"
    )
    print(
        "PASS: niri bindings, physical device key, mutable link, GUI edits, invalid/missing config"
    )
