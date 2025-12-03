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

configure_bat() {
    if command_exists bat; then
        local BAT_THEMES_DIR="${HOME}/.config/bat/themes"
        local CATPPUCCIN_BASE_URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes"

        if [ ! -f "${BAT_THEMES_DIR}/Catppuccin Latte.tmTheme" ]; then
            log_info "Installing Catppuccin themes for bat/delta..."
            mkdir -p "${BAT_THEMES_DIR}"

            curl -sL -o "${BAT_THEMES_DIR}/Catppuccin Latte.tmTheme" "${CATPPUCCIN_BASE_URL}/Catppuccin%20Latte.tmTheme"
            curl -sL -o "${BAT_THEMES_DIR}/Catppuccin Frappe.tmTheme" "${CATPPUCCIN_BASE_URL}/Catppuccin%20Frappe.tmTheme"
            curl -sL -o "${BAT_THEMES_DIR}/Catppuccin Macchiato.tmTheme" "${CATPPUCCIN_BASE_URL}/Catppuccin%20Macchiato.tmTheme"
            curl -sL -o "${BAT_THEMES_DIR}/Catppuccin Mocha.tmTheme" "${CATPPUCCIN_BASE_URL}/Catppuccin%20Mocha.tmTheme"

            # Rebuild bat cache to recognize new themes
            bat cache --build

            log_success "Catppuccin themes installed for bat/delta"
        else
            log_info "Catppuccin themes already installed for bat"
        fi
    fi
}

setup_configuration() {
    setup_brew_packages
    configure_iterm
    configure_tmux
    configure_bat
}
