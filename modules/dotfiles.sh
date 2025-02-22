# List of packages to skip
SKIP_PACKAGES=("aichat" "ssh" "gh" "git")

# Backup directory
BACKUP_DIR="${HOME}/.dotfiles_backup"

# Function to backup a file
backup_file() {
    local target_file="$1"
    local backup_path="${BACKUP_DIR}/${target_file:1}" # Remove leading slash from target_file
    local backup_dir_path=$(dirname "$backup_path")

    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then # Check if target exists and is not a symlink
        log_info "Backing up existing file: $target_file to $backup_path"
        mkdir -p "$backup_dir_path" || {
            log_error "Error creating backup directory: $backup_dir_path"
            return 1
        }
        mv "$target_file" "$backup_path" || {
            log_error "Error backing up file: $target_file to $backup_path"
            return 1
        }
    fi
}

# Function to check if a package should be skipped
should_skip_package() {
    local package="$1"
    for skip_package in "${SKIP_PACKAGES[@]}"; do
        if [[ "$package" == "$skip_package" ]]; then
            return 0 # Package should be skipped
        fi
    done
    return 1 # Package should not be skipped
}

setup_dotfiles() {
    # Get the directory of the current script
    SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

    # Get the parent directory
    PARENT_DIR=$(dirname "$SCRIPT_DIR")

    # Directory containing the dotfiles
    DOTFILES_DIR="${PARENT_DIR}/dotfiles"

    # # Clone dotfiles repository if it doesn't exist
    # if [ ! -d ~/dotfiles ]; then
    #     echo "Cloning dotfiles repository..."
    #     git clone https://github.com/yashhere/dotfiles.git ~/dotfiles
    # else
    #     echo "Dotfiles repository already exists. Updating..."
    #     cd ~/dotfiles && git pull
    # fi

    # Environment file paths
    SOURCE_ENV="${PARENT_DIR}/secrets/.env"
    TARGET_ENV="${HOME}/.env"

    # Handle .env file
    if [ -f "$SOURCE_ENV" ]; then
        cp "$SOURCE_ENV" "$TARGET_ENV" || {
            log_error "Error copying .env file"
            return 1
        }
    else
        touch "$SOURCE_ENV" || {
            log_error "Error creating .env file"
            return 1
        }
        log_info "Created empty .env file at $SOURCE_ENV"
        cp "$SOURCE_ENV" "$TARGET_ENV"
    fi
    chmod 600 "$TARGET_ENV"

    # Get all directories in DOTFILES_DIR
    PACKAGES=($(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

    # Loop through each package and stow it
    for package in "${PACKAGES[@]}"; do
        if should_skip_package "$package"; then
            log_warning "Skipping package $package (excluded)"
            continue
        fi

        if ! command_exists "$package"; then
            log_warning "$package is not installed. Skipping dotfile setup"
        else
            log_info "Stowing $package..."

            # Create backup directory for this stow run if it doesn't exist
            mkdir -p "$BACKUP_DIR"

            # Find potential conflicting files and backup before stow
            find "$DOTFILES_DIR/$package" -type f -print0 | while IFS= read -r -d $'\0' dotfile_source; do
                target_file="${HOME}/${dotfile_source#"$DOTFILES_DIR/$package/"}"
                backup_file "$target_file"
            done

            stow -v --no-folding -d "$DOTFILES_DIR" -t ~ "$package"

            # uncomment to un-stow
            # stow -v -D -d "$DOTFILES_DIR" -t ~ "$package"
        fi
    done

    log_info "Dotfiles stowed successfully! Backups (if any) are in $BACKUP_DIR"
}
