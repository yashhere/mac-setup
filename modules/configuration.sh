#!/usr/bin/env bash

setup_brew_packages() {
    # Save Homebrew’s installed location.
    BREW_PREFIX=$(brew --prefix)

    # Use gnu utilities
    # Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
    ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

    # Add brew-installed bash to available shells
    if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
        echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
    fi

    # Remove outdated versions from the cellar.
    brew cleanup
    brew cask cleanup
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

    if ! asdf plugin-list | grep -Fq "$name"; then
        asdf plugin-add "$name" "$url"
    else
        asdf plugin-update "$name"
    fi
}

install_asdf_language() {
    local language="$1"
    local version
    version="$(asdf list-all "$language" | grep -v "[a-z]" | tail -1)"

    if ! asdf list "$language" | grep -Fq "$version"; then
        log_echo "Installing latest $language"
        asdf install "$language" "$version"
        asdf global "$language" "$version"
    fi
}

configure_ruby() {
    log_echo "Configuring Ruby"
    gem update --system
    number_of_cores=$(sysctl -n hw.ncpu)
    bundle config --global jobs $((number_of_cores - 1))
}

configure_rust() {
    log_echo "Configuring Rust"
}

configure_python() {
    log_echo "Configuring Python"
}

configure_nodejs() {
    log_echo "Configuring Node"
}

configure_golang() {
    log_echo "Configuring Golang"
}

# Function to install asdf plugins and versions
configure_asdf() {
    log_info "Installing asdf plugins..."
    add_or_update_asdf_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
    add_or_update_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
    add_or_update_asdf_plugin "python" "https://github.com/asdf-vm/asdf-python.git"
    add_or_update_asdf_plugin "golang" "https://github.com/asdf-vm/asdf-golang.git"
    add_or_update_asdf_plugin "rust" "https://github.com/asdf-vm/asdf-rust.git"

    install_asdf_language "ruby"
    configure_ruby

    install_asdf_language "python"
    configure_python

    install_asdf_language "golang"
    configure_golang

    install_asdf_language "rust"
    configure_rust

    install_asdf_language "nodejs"
    configure_nodejs

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
