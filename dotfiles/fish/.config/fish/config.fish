if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
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
set -gx HOMEBREW_NO_AUTO_UPDATE true

# Load Vscode shell integration
string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

set work_config ~/.config/fish/config.work.fish
test -r $work_config; and source $work_config

# uv
fish_add_path "$HOME/.local/bin"

# LM Studio CLI
fish_add_path /Users/yagarwal/.lmstudio/bin

# Direnv hook - filter out routine loading messages but keep errors/blocks
direnv hook fish | source
function __direnv_export_eval --on-event fish_prompt
    eval (direnv export fish 2>&1 | string match -rv '^direnv: (loading|export)' | string collect)
end

# Initialize zoxide as cd replacement (smarter cd)
if type -q zoxide
    zoxide init fish --cmd cd | source
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.fish.inc' ]
    . '/opt/homebrew/share/google-cloud-sdk/path.fish.inc'
end
