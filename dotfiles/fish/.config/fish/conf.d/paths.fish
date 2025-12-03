# # Setting up the Path
# set -e fish_user_paths

# Bun
fish_add_path "$HOME/.bun"

# Local scripts
fish_add_path $HOME/.local/bin

# FZF configuration - use fd for file finding (respects .gitignore)
if type -q fd
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
end

# FZF appearance
set -gx FZF_DEFAULT_OPTS "\
--height 40% \
--layout=reverse \
--border \
--info=inline \
--preview-window=right:50%:hidden \
--bind='ctrl-/:toggle-preview'"

# # Docker
# set -g fish_user_paths $HOME/.docker/bin $fish_user_paths
