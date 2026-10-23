#!/usr/bin/env bash
# Bump pkg/zed-editor-bin to the latest Zed release.
# Fetches the latest tag from GitHub, hashes both arch DMGs, and rewrites
# the version + hashes in default.nix.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pkg_file="$repo_root/pkg/zed-editor-bin/default.nix"

# Location to prefetch from (empty = current machine).
sys="${1:-}"

current_version=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$pkg_file" | head -1)

tag=$(curl -fsSL https://api.github.com/repos/zed-industries/zed/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
if [[ -z "$tag" ]]; then
  echo "error: failed to fetch latest release tag" >&2
  exit 1
fi

if [[ "$tag" == "$current_version" ]]; then
  echo "already up to date: $current_version"
  exit 0
fi

echo "bumping zed-editor-bin: $current_version -> $tag"

hash_for() {
  local arch="$1" url
  url="https://github.com/zed-industries/zed/releases/download/v$tag/Zed-$arch.dmg"
  if [[ "$sys" == "--nix" ]]; then
    nix store prefetch-file --json --hash-type sha256 "$url" | sed -n 's/.*"hash": *"\([^"]*\)".*/\1/p'
  else
    nix --extra-experimental-features nix-command hash convert --hash-algo sha256 \
      "$(nix --extra-experimental-features nix-command store prefetch-file --json "$url" | sed -n 's/.*"hash": *"\([^"]*\)".*/\1/p')"
  fi
}

aarch64_hash=$(hash_for aarch64)
x86_64_hash=$(hash_for x86_64)

python3 - "$pkg_file" "$tag" "$aarch64_hash" "$x86_64_hash" <<'EOF'
import re, sys

path, version, aarch64, x86_64 = sys.argv[1:5]
with open(path) as f:
    src = f.read()

src = re.sub(r'(?m)^(  version = ")[^"]*(";\s*)$', rf'\g<1>{version}\g<2>', src, count=1)
src = re.sub(r'(?m)^(    aarch64 = ")[^"]*(";\s*)$', rf'\g<1>{aarch64}\g<2>', src, count=1)
src = re.sub(r'(?m)^(    x86_64 = ")[^"]*(";\s*)$', rf'\g<1>{x86_64}\g<2>', src, count=1)

with open(path, "w") as f:
    f.write(src)
EOF

echo "updated $pkg_file"
