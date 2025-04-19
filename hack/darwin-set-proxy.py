import os
import plistlib
import shlex
import sys
import argparse
import subprocess
from pathlib import Path

NIX_DAEMON_PLIST = Path("/Library/LaunchDaemons/org.nixos.nix-daemon.plist")
NIX_DAEMON_NAME = "org.nixos.nix-daemon"

PLIST = plistlib.loads(NIX_DAEMON_PLIST.read_bytes())

def update_plist():
    os.chmod(NIX_DAEMON_PLIST, 0o644)
    NIX_DAEMON_PLIST.write_bytes(plistlib.dumps(PLIST))
    os.chmod(NIX_DAEMON_PLIST, 0o444)

def reload_daemon():
    for cmd in (
        f"launchctl unload {NIX_DAEMON_PLIST}",
        f"launchctl load {NIX_DAEMON_PLIST}",
        f"launchctl kickstart -k system/{NIX_DAEMON_NAME}",
    ):
        print(cmd)
        subprocess.run(shlex.split(cmd), capture_output=False)

env_key = "EnvironmentVariables"


def set_proxy(proxy):
    proxy_dict = {
        "http_proxy": proxy,
        "https_proxy": proxy,
    }
    if PLIST.get(env_key) is None:
        PLIST[env_key] = {}
        PLIST.setdefault(env_key,proxy_dict)
    else:
        PLIST[env_key].update(proxy_dict)
    update_plist()
    reload_daemon()

def unset_proxy():
    if PLIST.get(env_key) is not None:
        PLIST[env_key].pop("http_proxy",None)
        PLIST[env_key].pop("https_proxy",None)
        update_plist()
        reload_daemon()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='a python scripts to add proxy set for nix-daemon in macos',
        add_help=False
    )
    
    group = parser.add_mutually_exclusive_group()
    
    group.add_argument('-u', '--unset', action='store_true', help='unset proxy')
    group.add_argument('-s', '--set', metavar="proxy_addr", help='set proxy')
    group.add_argument('-h', '--help', action='store_true', help='show this help')
    args = parser.parse_args()
    if args.help or len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)
    
    specified_args = sum([args.unset is not False, args.set is not None, args.help])
    if specified_args > 1:
        print("Error: arguments -u/--unset、-s/--set 和 -h/--help 是互斥的，不能同时使用", file=sys.stderr)
        parser.print_help()
        sys.exit(1)
    
    if args.set is not None and not args.set.strip():
        print("Error: -s/--set argument need to specified proxy addr", file=sys.stderr)
        parser.print_help()
        sys.exit(1)

    if args.unset:
        unset_proxy()
    elif args.set:
        set_proxy(args.set)
