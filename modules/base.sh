#!/usr/bin/env bash

BREWFILE="$SCRIPT_DIR/Brewfile"

APP_STORE_PACKAGES=(
    "1091189122::Bear"
    "409183694::Keynote"
    "409203825::Numbers"
    "409201541::Pages"
)

install_xcode_cli_tools() {
    if command -v xcodebuild &>/dev/null; then
        log_info "Xcode Command Line Tools already installed. Skipping."
    else
        log_info "Installing Xcode Command Line Tools…"
        xcode-select --install
        if [[ $? -eq 0 ]]; then
            log_info "Xcode Command Line Tools installed!"
        else
            log_error "Xcode Command Line Tools installation failed!"
            return 1
        fi
    fi

    if is_apple_silicon; then
        if ! pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
            log_info "Installing Rosetta"
            softwareupdate --install-rosetta --agree-to-license
            if [[ $? -eq 0 ]]; then
                log_info "Rosetta installed!"
            else
                log_error "Rosetta installation failed!"
                return 1
            fi
        else
            log_info "Rosetta is installed"
        fi
    fi
    return 0
}

install_homebrew() {
    # Install Homebrew if not already installed
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH based on architecture
        if is_apple_silicon; then
            # For Apple Silicon
            if [[ ! -f ~/.zprofile ]] || ! grep -q "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" ~/.zprofile; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
            fi
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # For Intel Macs
            if [[ ! -f ~/.zprofile ]] || ! grep -q "eval \"\$(/usr/local/bin/brew shellenv)\"" ~/.zprofile; then
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >>~/.zprofile
            fi
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        log_success "Homebrew installed successfully!"
    else
        log_info "Homebrew already installed, updating..."
        brew update
    fi
}

install_packages() {
    # Create Brewfile if it doesn't exist
    if [ ! -f "$BREWFILE" ]; then
        log_info "Creating Brewfile template..."
        cat >"$BREWFILE" <<EOF
# Taps
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"

# Command line tools
brew "gnu-stow"
brew "fish"
brew "git"
brew "wget"
brew "curl"
brew "coreutils"
brew "findutils"

# Version managers
brew "asdf"

# Development tools
# brew "vim"
# brew "neovim"
# brew "tmux"

# Productivity apps
# cask "rectangle"
# cask "alfred"

# Communication apps
# cask "slack"

# Media apps
# cask "vlc"
EOF
        log_info "Please edit $BREWFILE with your preferred applications and run again."
    fi

    # Install from Brewfile
    log_info "Installing applications from Brewfile..."
    brew bundle --file="$BREWFILE"

    log_info "Homebrew packages installation completed."
}

mas_setup() {
    return 1
    # https://github.com/mas-cli/mas#known-issues
    # if mas account >/dev/null; then
    #     return 0
    # else
    #     return 1
    # fi
}

install_app_store_packages() {
    if ! command_exists mas; then
        brew install mas
    fi

    if mas_setup; then
        for app in ${APP_STORE_PACKAGES[@]}; do
            APP_ID="${app%%::*}"
            APP_NAME="${app##*::}"
            if ! mas list | grep $APP_ID &>/dev/null; then
                log_info "Installing $APP_NAME"
                mas install $APP_ID >/dev/null
            fi
        done
    else
        log_error "Please signin to App Store first. Skipping."
    fi
}

configure_host() {
    # sudo scutil --set ComputerName "${COMPUTER_NAME:-mac}"
    # sudo scutil --set LocalHostName "${COMPUTER_NAME:-mac}"
    # sudo scutil --set HostName "${COMPUTER_NAME:-mac}"

    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist NetBIOSName -string "${COMPUTER_NAME:-mac}"

    if [ -z "$XDG_CONFIG_HOME" ]; then
        log_info "Setting up ~/.config directory..."
        if [ ! -d "${HOME}/.config" ]; then
            mkdir "${HOME}/.config"
        fi
        export XDG_CONFIG_HOME="${HOME}/.config"
    fi

    if [ ! -d "${HOME}/.local/bin" ]; then
        log_info "Setting up ~/.local/bin directory..."
        mkdir -pv "${HOME}/.local/bin"
    fi
}

setup_base() {
    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until `base.sh` has finished
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &

    install_xcode_cli_tools
    install_homebrew
    install_packages
    install_app_store_packages
}
