#!/bin/bash

# Function to install asdf plugins and versions
setup_asdf_languages() {
    # Install asdf plugins
    log_info "Installing asdf plugins..."
    asdf plugin add python https://github.com/asdf-community/asdf-python.git || log_info "Python plugin already installed."
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git || log_info "Node.js plugin already installed."
    asdf plugin add golang https://github.com/asdf-community/asdf-golang.git || log_info "Go plugin already installed."
    asdf plugin add rust https://github.com/asdf-community/asdf-rust.git || log_info "Rust plugin already installed."

    # Install versions specified in .tool-versions
    log_info "Installing versions from .tool-versions..."
    asdf install

    # Set global versions
    log_info "Setting global versions..."
    asdf global python 3.13.0
    asdf global nodejs 23.8.0
    asdf global golang 1.24.0
    asdf global rust 1.85.0

    # Verify installations
    log_info "Verifying installations..."
    asdf current
}

setup_dev() {
    # Run the setup function
    setup_asdf_languages

}
