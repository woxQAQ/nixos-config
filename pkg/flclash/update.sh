#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused jq yq-go bash nix nix-prefetch-git ripgrep

set -eou pipefail

PACKAGE_DIR=$(realpath "$(dirname "$0")")
REPO_ROOT=$(realpath "$PACKAGE_DIR/../..")
cd "$REPO_ROOT"

# The flake exposes no packages output; evaluate through the host config so
# the package sees the exact nixpkgs/overlay set the system builds with.
FLAKE_ATTR='.#nixosConfigurations.woxQAQ.pkgs'

pkgAttr() {
    nix eval --raw "$FLAKE_ATTR.flclash.$1"
}

latestTag=$(curl --fail --location --silent ${GITHUB_TOKEN:+--user ":$GITHUB_TOKEN"} https://api.github.com/repos/chen08209/FlClash/releases/latest | jq --raw-output .tag_name)
latestVersion=${latestTag#v}

currentVersion=$(pkgAttr version)

if [[ "$currentVersion" == "$latestVersion" ]]; then
    echo "package is up-to-date: $currentVersion"
    exit 0
fi

sed -i "s/  version = \"$currentVersion\";/  version = \"$latestVersion\";/" "$PACKAGE_DIR/default.nix"

# fetchFromGitHub fetches submodules, and its preFetch rewrites git@ URLs.
newSrcHash=$(
    GIT_CONFIG_COUNT=1 \
    GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf \
    GIT_CONFIG_VALUE_0=git@github.com: \
    nix-prefetch-git --url https://github.com/chen08209/FlClash --rev "$latestTag" --fetch-submodules --quiet \
    | jq --raw-output .hash
)
sed -i "0,/    hash = \"sha256-[^\"]*\";/s//    hash = \"$newSrcHash\";/" "$PACKAGE_DIR/default.nix"

# Rebuild each fixed-output hash by building with a fake hash and reading the
# mismatch. $1: package attribute to build, $2: sed script pinning the line.
fixHash() {
    local attr=$1 anchor=$2 got
    sed -i "$anchor" "$PACKAGE_DIR/default.nix"
    got=$(nix build "$FLAKE_ATTR.flclash.$attr" 2>&1 \
        | rg --only-matching --replace '$1' 'got:\s+(\S+)' | tail -1)
    if [[ -z "$got" ]]; then
        echo "failed to obtain new hash for $attr" >&2
        exit 1
    fi
    sed -i "0,/hash = lib.fakeHash;/s//hash = \"$got\";/" "$PACKAGE_DIR/default.nix"
}

fixHash core 's|vendorHash = "[^"]*";|vendorHash = lib.fakeHash;|'
fixHash cargoDeps '/cargoRoot = "plugins\/rust_api\/rust";/{n;s|hash = .*;|hash = lib.fakeHash;|;}'
fixHash helperCargoDeps '/cargoRoot = "services\/helper";/{n;s|hash = .*;|hash = lib.fakeHash;|;}'

curl --fail --location --silent "https://raw.githubusercontent.com/chen08209/FlClash/$latestTag/pubspec.lock" \
    | yq eval --output-format=json --prettyPrint > "$PACKAGE_DIR/pubspec.lock.json"
"$(nix eval --raw "$FLAKE_ATTR.dart.fetchGitHashesScript")" \
    --input "$PACKAGE_DIR/pubspec.lock.json" --output "$PACKAGE_DIR/git-hashes.json"

nix build "$FLAKE_ATTR.flclash"
