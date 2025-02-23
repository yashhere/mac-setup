#!/usr/bin/env bash

setup_brew_packages() {
    # Save Homebrew’s installed location.
    BREW_PREFIX=$(brew --prefix)

    # Use gnu utilities
    # Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
    ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum" >/dev/null 2>&1

    # Add brew-installed bash to available shells
    if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
        echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
    fi

    # Remove outdated versions from the cellar.
    brew cleanup
}

configure_iterm() {
    if [ -d "/Applications/iTerm.app" ]; then
        log_info "Setting up iTerm2 preferences..."

        # Specify the preferences directory
        defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$DOTFILES_DIR/iterm"

        # Tell iTerm2 to use the custom preferences in the directory
        defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
    fi
}

configure_tmux() {
    if command_exists tmux; then
        if [ ! -d "${HOME}/.terminfo" ]; then
            log_info "Installing custom terminfo entries..."
            # These entries enable, among other things, italic text in the terminal.
            tic -x "${DOTFILES_DIR}/terminfo/tmux-256color.terminfo"
            tic -x "${DOTFILES_DIR}/terminfo/xterm-256color-italic.terminfo"
        fi

        if [ ! -d "${DOTFILES_DIR}/tmux/.config/tmux/plugins" ]; then
            log_info "Installing Tmux Plugin Manager..."
            git clone https://github.com/tmux-plugins/tpm "${DOTFILES_DIR}/tmux/.config/tmux/plugins/tpm"
        fi
    fi
}

add_or_update_asdf_plugin() {
    local name="$1"
    local url="$2"

    if ! asdf plugin list | grep -q "$name"; then
        asdf plugin add "$name" "$url" >/dev/null 2>&1
    else
        asdf plugin update "$name" >/dev/null 2>&1
    fi
}

configure_ruby() {
    log_info "Configuring Ruby"
    gem update --system
    number_of_cores=$(sysctl -n hw.ncpu)
    bundle config --global jobs $((number_of_cores - 1))
}

configure_rust() {
    log_info "Configuring Rust"
}

configure_python() {
    log_info "Configuring Python"
    # Install pipx
    pip install --quiet --user pipx
    pipx ensurepath --quiet

    # Install common Python tools with pipx
    local python_tools=(
        black
        flake8
        mypy
        poetry
        pre-commit
        pytest
        jupyterlab
        thefuck
    )

    for tool in "${python_tools[@]}"; do
        log_info "Installing $tool..."
        pipx install "$tool" >/dev/null 2>&1
    done
}

configure_nodejs() {
    log_info "Configuring Node"
    local npm_packages=(
        typescript
        ts-node
        eslint
        prettier
        nodemon
        http-server
    )

    npm install -g "${npm_packages[@]}"
    log_success "Node.js development environment setup completed"
}

configure_golang() {
    log_info "Configuring Golang"
    GO_TOOLS=(
        "golang.org/x/tools/gopls@latest"                # Go language server
        "github.com/go-delve/delve/cmd/dlv@latest"       # Delve debugger
        "golang.org/x/tools/cmd/goimports@latest"        # Goimports
        "github.com/fatih/gomodifytags@latest"           # Go struct tag modifier
        "github.com/cweill/gotests/gotests@latest"       # Generate Go tests
        "github.com/ramya-rao-a/go-outline@latest"       # Go outline for VS Code
        "github.com/stamblerre/gocode@latest"            # Autocompletion daemon
        "github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest" # List available Go packages
        "github.com/josharian/impl@latest"               # Generate method implementations
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
    )

    for tool in "${GO_TOOLS[@]}"; do
        log_info "Installing $tool..."
        go install "$tool" >/dev/null 2>&1
    done
}

ensure_ruby() {
    log_info "Installing ruby"
    asdf install ruby >/dev/null 2>&1
    configure_ruby >/dev/null 2>&1
}

ensure_python() {
    log_info "Installing python"
    asdf install python >/dev/null 2>&1
    configure_python
}

ensure_golang() {
    log_info "Installing golang"
    asdf install golang >/dev/null 2>&1
    configure_golang
}

ensure_rust() {
    log_info "Installing rust"
    asdf install rust >/dev/null 2>&1
    configure_rust
}

ensure_nodejs() {
    log_info "Installing nodejs"
    asdf install nodejs >/dev/null 2>&1
    configure_nodejs
}

# Function to install asdf plugins and versions
configure_asdf() {
    log_info "Installing asdf plugins..."
    add_or_update_asdf_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
    add_or_update_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
    add_or_update_asdf_plugin "python" "https://github.com/asdf-vm/asdf-python.git"
    add_or_update_asdf_plugin "golang" "https://github.com/asdf-vm/asdf-golang.git"
    add_or_update_asdf_plugin "rust" "https://github.com/asdf-vm/asdf-rust.git"

    ensure_ruby
    ensure_python
    ensure_golang
    ensure_rust
    ensure_nodejs

    # Verify installations
    log_info "Verifying installations..."
    asdf current
}

setup_configuration() {
    setup_brew_packages
    configure_iterm
    configure_tmux
    configure_asdf
}
