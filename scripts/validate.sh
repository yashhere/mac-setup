#!/usr/bin/env bash
# Validation script for mac-setup
# Checks symlinks, configs, and tool availability

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Check if a command exists
check_command() {
    local cmd=$1
    local optional=${2:-false}

    if command -v "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC} Command available: $cmd"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        if [ "$optional" = "true" ]; then
            echo -e "${YELLOW}⚠${NC} Optional command missing: $cmd"
            CHECKS_WARNING=$((CHECKS_WARNING + 1))
        else
            echo -e "${RED}✗${NC} Command missing: $cmd"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
    fi
}

# Check if a symlink exists and is valid
check_symlink() {
    local link=$1
    local optional=${2:-false}

    if [ -L "$link" ]; then
        if [ -e "$link" ]; then
            echo -e "${GREEN}✓${NC} Symlink valid: $link"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            echo -e "${RED}✗${NC} Symlink broken: $link"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
    else
        if [ "$optional" = "true" ]; then
            echo -e "${YELLOW}⚠${NC} Optional symlink missing: $link"
            CHECKS_WARNING=$((CHECKS_WARNING + 1))
        else
            echo -e "${RED}✗${NC} Symlink missing: $link"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
    fi
}

# Validate JSON file
check_json() {
    local file=$1

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠${NC} JSON file not found: $file"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
        return
    fi

    if command -v jq &>/dev/null; then
        if jq empty "$file" &>/dev/null; then
            echo -e "${GREEN}✓${NC} JSON valid: $(basename "$file")"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            echo -e "${RED}✗${NC} JSON invalid: $file"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
    else
        echo -e "${YELLOW}⚠${NC} jq not installed, skipping JSON validation"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
    fi
}

# Validate YAML file
check_yaml() {
    local file=$1

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠${NC} YAML file not found: $file"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
        return
    fi

    if command -v yq &>/dev/null; then
        if yq eval '.' "$file" &>/dev/null; then
            echo -e "${GREEN}✓${NC} YAML valid: $(basename "$file")"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            echo -e "${RED}✗${NC} YAML invalid: $file"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
    else
        echo -e "${YELLOW}⚠${NC} yq not installed, skipping YAML validation"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
    fi
}

# Validate Fish functions
check_fish_functions() {
    if ! command -v fish &>/dev/null; then
        echo -e "${YELLOW}⚠${NC} Fish shell not installed, skipping function checks"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
        return
    fi

    local functions_dir="${REPO_DIR}/dotfiles/fish/.config/fish/functions"
    if [ ! -d "$functions_dir" ]; then
        echo -e "${RED}✗${NC} Fish functions directory not found"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return
    fi

    local func_count=0
    local func_errors=0

    for func_file in "$functions_dir"/*.fish; do
        [ -f "$func_file" ] || continue
        func_count=$((func_count + 1))

        if fish --no-execute "$func_file" &>/dev/null; then
            echo -e "${GREEN}✓${NC} Fish function valid: $(basename "$func_file")"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            echo -e "${RED}✗${NC} Fish function has syntax errors: $(basename "$func_file")"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
            func_errors=$((func_errors + 1))
        fi
    done

    echo "Found $func_count Fish functions ($func_errors errors)"
}

echo "========================================"
echo "  Mac-Setup Validation"
echo "========================================"
echo ""

echo "Checking essential commands..."
check_command "brew"
check_command "git"
check_command "stow"
check_command "fish"
check_command "tmux"
check_command "nvim" true
check_command "jq" true
check_command "yq" true
echo ""

echo "Checking essential symlinks..."
check_symlink "${HOME}/.config/fish/config.fish"
check_symlink "${HOME}/.config/tmux/tmux.conf"
check_symlink "${HOME}/.gitconfig"
check_symlink "${HOME}/.config/nvim" true
echo ""

echo "Validating configuration files..."
check_yaml "${REPO_DIR}/.pre-commit-config.yaml"
check_json "${REPO_DIR}/dotfiles/iterm/profiles/Mac.json" 2>/dev/null || true
echo ""

echo "Validating Fish functions..."
check_fish_functions
echo ""

echo "========================================"
echo "  Validation Summary"
echo "========================================"
echo -e "${GREEN}Passed:  $CHECKS_PASSED${NC}"
echo -e "${YELLOW}Warnings: $CHECKS_WARNING${NC}"
echo -e "${RED}Failed:  $CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the errors above.${NC}"
    exit 1
fi
