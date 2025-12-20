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
        log_info "Installing iTerm2 JSON profiles..."
        local PROFILE_DIR="${HOME}/Library/Application Support/iTerm2/DynamicProfiles"
        mkdir -p "$PROFILE_DIR"

        if [ -d "${DOTFILES_DIR}/iterm/profiles" ]; then
            cp "${DOTFILES_DIR}/iterm/profiles"/*.json "$PROFILE_DIR/" 2>/dev/null || true
            log_success "iTerm2 JSON profiles installed"
        fi
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

        TPM_DIR="${DOTFILES_DIR}/tmux/.config/tmux/plugins/tpm"
        if [ ! -d "$TPM_DIR" ]; then
            log_info "Installing Tmux Plugin Manager..."
            git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
        else
            log_info "TPM already installed, checking for updates..."
            (cd "$TPM_DIR" && git pull --quiet 2>/dev/null) || log_info "TPM update skipped (no git access)"
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
            log_info "Catppuccin themes already installed"
        fi
    fi
}

setup_configuration() {
    setup_brew_packages
    configure_iterm
    configure_tmux
    configure_bat
}
