import os
import plistlib
import shlex
import subprocess
from pathlib import Path

NIX_DAEMON_PLIST = Path("/Library/LaunchDaemons/org.nixos.nix-daemon.plist")
NIX_DAEMON_NAME = "org.nixos.nix-daemon"
HTTP_PROXY = "http://192.168.1.105:7890"

PLIST = plistlib.loads(NIX_DAEMON_PLIST.read_bytes())

def update_plist():
    os.chmod(NIX_DAEMON_PLIST, 0o644)
    NIX_DAEMON_PLIST.write_bytes(plistlib.dumps(PLIST))
    os.chmod(NIX_DAEMON_PLIST, 0o444)

def reload_daemon():
    for cmd in (
        f"launchctl unload {NIX_DAEMON_PLIST}",
        f"launchctl load {NIX_DAEMON_PLIST}"
    ):
        print(cmd)
        subprocess.run(shlex.split(cmd), capture_output=False)

env_key = "EnvironmentVariables"
proxy_dict = {
    "http_proxy": HTTP_PROXY,
    "https_proxy": HTTP_PROXY,
}

def set_proxy():
    # print(type(PLIST))
    print(PLIST)
    PLIST.setdefault(env_key,proxy_dict)
    print(PLIST)
    # PLIST["EnvironmentVariables"]["http_proxy"]= HTTP_PROXY
    # PLIST["EnvironmentVariables"]["https_proxy"]= HTTP_PROXY
    update_plist()
    reload_daemon()

def unset_proxy():
    if PLIST.get(env_key) is not None:
        PLIST[env_key].pop("http_proxy",None)
        PLIST[env_key].pop("https_proxy",None)
        update_plist()
        reload_daemon()

if __name__ == "__main__":
    set_proxy()