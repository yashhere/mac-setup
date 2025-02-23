if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting

# Install Fisher if it's not installed
if not functions -q fisher && status is-interactive
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update
end


if test (arch) = arm64
    eval (/opt/homebrew/bin/brew shellenv)
else
    eval (/usr/local/bin/brew shellenv)
end

# Environment variables - https://fishshell.com/docs/current/cmds/set.html
set -gx EDITOR vim
set -gx GIT_EDITOR vim
set -gx MANPAGER 'less -X' # Don’t clear the screen after quitting a manual page
set -gx HOMEBREW_CASK_OPTS '--appdir=/Applications'
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx DOTFILES "$HOME/dotfiles"

# ASDF configuration code
set -gx ASDF_DATA_DIR $HOME/.asdf
source (brew --prefix asdf)/share/fish/vendor_completions.d/asdf.fish
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

# Load Vscode shell integration
string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

# Fabric
# Loop through all files in the ~/.config/fabric/patterns directory
for pattern_file in $HOME/.config/fabric/patterns/*
    # Get the base name of the file (i.e., remove the directory path)
    set pattern_name (basename "$pattern_file")

    # Create an alias in the form: alias pattern_name="fabric --pattern pattern_name"
    alias $pattern_name="fabric --pattern $pattern_name"
end

# Define the yt function
function yt
    set video_link "$argv[1]"
    fabric -y "$video_link" --transcript
end
