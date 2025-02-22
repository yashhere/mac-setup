BREWFILE="$SCRIPT_DIR/Brewfile"

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

setup_base() {
    install_homebrew
    install_packages
}
