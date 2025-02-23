#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Root directory of the setup scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"
LOG_FILE="${SCRIPT_DIR}/setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running on Apple Silicon
is_apple_silicon() {
    [[ "$(uname -m)" == "arm64" ]]
}

# Check if running on MacBook (portable) vs desktop Mac
is_macbook() {
    # Check if battery exists
    system_profiler SPPowerDataType 2>/dev/null | grep -q "Battery Information"
}

# Function to ensure a directory exists
ensure_dir_exists() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    fi
}

# Logging functions
log_info() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} - $1" | tee -a "${LOG_FILE}"
}

log_error() { log_info "${RED}ERROR: $1${NC}"; }
log_success() { log_info "${GREEN}SUCCESS: $1${NC}"; }
log_warning() { log_info "${YELLOW}WARNING: $1${NC}"; }

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Function to source and run a module
run_module() {
    local module_name=$1
    local module_path="${MODULES_DIR}/${module_name}.sh"

    if [[ ! -f "$module_path" ]]; then
        log_error "Module not found: ${module_path}"
        return 1
    fi

    log_info "Running module: ${module_name}"
    source "$module_path"

    if ! declare -F "setup_${module_name}" >/dev/null; then
        log_error "Module ${module_name} does not contain required function setup_${module_name}"
        return 1
    fi

    "setup_${module_name}"
    log_success "Module ${module_name} completed"
}

# List available modules
list_modules() {
    log_info "Available modules:"
    for module in "${MODULES_DIR}"/*.sh; do
        [[ -f "$module" ]] || continue
        basename "$module" .sh
    done
}

check_macos() {
    osname=$(uname)

    if [ "$osname" != "Darwin" ]; then
        log_info "Oops, it looks like you're using a non-Apple system. Sorry, this script only supports macOS. Exiting..."
        exit 1
    fi
}

# Main setup function
main() {
    check_macos

    local modules=(
        "base"     # Basic system configuration
        "dotfiles" # GNU Stow dotfiles setup
        "configuration"
        "system_prefs"
    )

    # setup.sh
    if [ -f .env ]; then
        set -a # automatically export all variables
        source .env
        set +a
    else
        log_error "Error: .env file not found"
        exit 1
    fi

    # Create necessary directories
    mkdir -p "${MODULES_DIR}"
    : >"${LOG_FILE}"

    log_info "Starting MacOS setup script"
    check_root

    # Run single module if specified
    if [[ -n "${SINGLE_MODULE:-}" ]]; then
        run_module "$SINGLE_MODULE"
        exit $?
    fi

    # Run all modules
    for module in "${modules[@]}"; do
        if ! run_module "$module"; then
            log_error "Failed to run module: ${module}"
            exit 1
        fi
    done

    log_success "Setup completed successfully"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --module)
        SINGLE_MODULE="$2"
        shift 2
        ;;
    --list-modules)
        list_modules
        exit 0
        ;;
    --help)
        log_error "Usage: $0 [--skip-network] [--module <module_name>] [--list-modules] [--help]"
        exit 0
        ;;
    *)
        log_error "Unknown option: $1"
        exit 1
        ;;
    esac
done

main "$@"
