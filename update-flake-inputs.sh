#!/usr/bin/env bash

# TUI script for updating flake inputs
# Usage: ./update-flake-inputs.sh

set -e

FLAKE_FILE="$(dirname "$0")/flake.nix"
NIX_FLAGS="--extra-experimental-features 'nix-command flakes'"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if fzf is available
if ! command -v fzf &> /dev/null; then
    echo -e "${RED}Error: fzf is not installed.${NC}"
    echo "Please install fzf to use this script."
    exit 1
fi

# Extract input names from flake using nix
get_inputs() {
    # Use nix to get the locked nodes from flake.lock
    if [ -f "$(dirname "$0")/flake.lock" ]; then
        nix eval --json '.#rootInputs' 2>/dev/null | jq -r 'keys[]' 2>/dev/null || \
        nix flake metadata --json 2>/dev/null | jq -r '.locks.nodes.root.inputs | keys[]' 2>/dev/null
    fi
}

# Fallback: extract from flake.nix using grep
get_inputs_fallback() {
    grep -E '^\s+[a-zA-Z0-9_-]+\s*=\s*\{' "$(dirname "$0")/flake.nix" | \
        sed -E 's/^\s+([a-zA-Z0-9_-]+).*/\1/' | grep -v '^inputs$'
}

# Run nix flake update
update_input() {
    local input_name="$1"
    echo -e "${CYAN}Updating input: ${YELLOW}$input_name${NC}"

    if [ -z "$input_name" ] || [ "$input_name" == "[update-all-inputs]" ]; then
        nix flake update
    else
        nix flake update "$input_name"
    fi
}

# Main function
main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     ${CYAN}Nix Flake Inputs Updater${BLUE}                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check if flake.nix exists
    if [ ! -f "$FLAKE_FILE" ]; then
        echo -e "${RED}Error: flake.nix not found at $FLAKE_FILE${NC}"
        exit 1
    fi

    echo -e "${CYAN}Parsing flake.nix for inputs...${NC}"

    # Get inputs and add special options
    local inputs
    inputs=$(get_inputs 2>/dev/null | sort -u)

    # Fallback if nix method didn't work
    if [ -z "$inputs" ]; then
        inputs=$(get_inputs_fallback | sort -u)
    fi

    if [ -z "$inputs" ]; then
        echo -e "${RED}No inputs found in flake.nix${NC}"
        exit 1
    fi

    # Prepare fzf options
    local fzf_input="[update-all-inputs]\n$inputs"

    echo ""
    echo -e "${CYAN}Select an input to update (use arrow keys, Enter to select):${NC}"
    echo ""

    # Run fzf
    local selected
    selected=$(echo -e "$fzf_input" | fzf \
        --prompt="Select input > " \
        --height=20 \
        --border=rounded \
        --header="Select an input to update | First option updates ALL inputs" \
        --preview="echo 'Input: {}'" \
        --preview-window=hidden \
        --color='header:green:bold,prompt:blue:bold,info:yellow,marker:cyan')

    if [ -z "$selected" ]; then
        echo ""
        echo -e "${YELLOW}No input selected. Exiting.${NC}"
        exit 0
    fi

    echo ""
    if [ "$selected" == "[update-all-inputs]" ]; then
        echo -e "${GREEN}You selected: Update ALL inputs${NC}"
    else
        echo -e "${GREEN}You selected input: ${CYAN}$selected${NC}"
    fi

    # Confirm
    echo ""
    read -rp "Proceed with update? [Y/n]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]] && [ -n "$confirm" ]; then
        echo -e "${YELLOW}Update cancelled.${NC}"
        exit 0
    fi

    echo ""
    update_input "$selected"

    echo ""
    echo -e "${GREEN}✓ Update complete!${NC}"
}

main "$@"
