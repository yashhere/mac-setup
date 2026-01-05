# Modern fish prompt with Catppuccin Latte colors
# Clean two-line prompt with git integration

# Disable default virtualenv prompt (we handle it ourselves)
set -g VIRTUAL_ENV_DISABLE_PROMPT 1

# Catppuccin Latte palette
set -g __fish_prompt_color_cwd 1e66f5        # Blue
set -g __fish_prompt_color_git_clean 40a02b  # Green
set -g __fish_prompt_color_git_dirty df8e1d  # Yellow
set -g __fish_prompt_color_git_staged 8839ef # Mauve
set -g __fish_prompt_color_error d20f39      # Red
set -g __fish_prompt_color_duration 7c7f93   # Overlay 1
set -g __fish_prompt_color_dim 9ca0b0        # Overlay 0
set -g __fish_prompt_color_prompt 04a5e5     # Sky
set -g __fish_prompt_color_venv 179299       # Teal
set -g __fish_prompt_color_ssh d20f39        # Red (for SSH indicator)

function __prompt_git_info
    # Fast check if we're in a git repo
    set -l git_dir (command git rev-parse --git-dir 2>/dev/null)
    or return

    # Get branch name
    set -l branch (command git symbolic-ref --short HEAD 2>/dev/null)
    or set branch (command git describe --tags --exact-match HEAD 2>/dev/null)
    or set branch (command git rev-parse --short HEAD 2>/dev/null)

    # Check status (staged, unstaged, untracked)
    set -l git_status (command git status --porcelain 2>/dev/null)
    
    set -l staged 0
    set -l unstaged 0
    set -l untracked 0
    
    for line in $git_status
        switch (string sub -l 2 $line)
            case 'A ' 'M ' 'D ' 'R ' 'C '
                set staged 1
            case ' M' ' D' 'AM' 'MM'
                set unstaged 1
            case '\?\?'
                set untracked 1
        end
    end

    # Choose color based on state
    if test $staged -eq 1
        set_color $__fish_prompt_color_git_staged
    else if test $unstaged -eq 1 -o $untracked -eq 1
        set_color $__fish_prompt_color_git_dirty
    else
        set_color $__fish_prompt_color_git_clean
    end

    echo -n " $branch"

    # Status indicators
    set -l indicators ""
    test $staged -eq 1; and set indicators "$indicators+"
    test $unstaged -eq 1; and set indicators "$indicators!"
    test $untracked -eq 1; and set indicators "$indicators?"

    if test -n "$indicators"
        echo -n " $indicators"
    end

    # Ahead/behind
    set -l ahead_behind (command git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null | string split \t)
    if test (count $ahead_behind) -eq 2
        set -l ahead $ahead_behind[1]
        set -l behind $ahead_behind[2]
        if test $ahead -gt 0
            echo -n " ↑ $ahead"
        end
        if test $behind -gt 0
            echo -n " ↓ $behind"
        end
    end

    set_color normal
end

function __prompt_venv
    # Show Python virtual environment
    if test -n "$VIRTUAL_ENV"
        set -l venv_name (basename $VIRTUAL_ENV)
        set_color $__fish_prompt_color_venv
        echo -n " ($venv_name)"
        set_color normal
    else if test -n "$CONDA_DEFAULT_ENV"
        set_color $__fish_prompt_color_venv
        echo -n " ($CONDA_DEFAULT_ENV)"
        set_color normal
    end
end

function __prompt_ssh
    # Show prominent SSH indicator when in SSH session
    if test -n "$SSH_CLIENT$SSH2_CLIENT$SSH_TTY"
        set_color --bold $__fish_prompt_color_ssh
        echo -n " [SSH:"
        set_color --bold --underline $__fish_prompt_color_ssh
        echo -n (hostname -s)
        set_color --bold $__fish_prompt_color_ssh
        echo -n "]"
        set_color normal
    end
end

function __prompt_duration
    # Only show if command took longer than 3 seconds
    if test $CMD_DURATION -gt 3000
        set -l duration $CMD_DURATION
        set -l hours (math -s0 $duration / 3600000)
        set -l mins (math -s0 $duration % 3600000 / 60000)
        set -l secs (math -s0 $duration % 60000 / 1000)

        set_color $__fish_prompt_color_duration
        echo -n " "
        if test $hours -gt 0
            echo -n {$hours}h
        end
        if test $mins -gt 0
            echo -n {$mins}m
        end
        echo -n {$secs}s
        set_color normal
    end
end

function __prompt_pwd
    set -l pwd_full (pwd)
    set -l pwd_display (string replace "$HOME" "~" $pwd_full)
    
    # Highlight git repo root differently
    set -l git_root (command git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$git_root"
        set -l repo_name (basename $git_root)
        set -l relative_path (string replace $git_root "" $pwd_full)
        set -l parent_path (string replace "$HOME" "~" (dirname $git_root))
        
        if test "$parent_path" != "~"
            set_color $__fish_prompt_color_dim
            echo -n "$parent_path/"
        else
            set_color $__fish_prompt_color_dim
            echo -n "~/"
        end
        
        set_color --bold $__fish_prompt_color_cwd
        echo -n "$repo_name"
        set_color normal
        set_color $__fish_prompt_color_dim
        echo -n "$relative_path"
        set_color normal
    else
        set_color $__fish_prompt_color_cwd
        echo -n $pwd_display
        set_color normal
    end
end

function fish_prompt
    set -l last_status $status

    # Line 1: path + SSH indicator + git + venv
    echo
    __prompt_pwd
    __prompt_ssh
    __prompt_git_info
    __prompt_venv
    __prompt_duration
    echo

    # Line 2: prompt character
    if test $last_status -eq 0
        set_color $__fish_prompt_color_prompt
    else
        set_color $__fish_prompt_color_error
    end
    echo -n "❯ "
    set_color normal
end

function fish_right_prompt
    # SSH indicator
    if test -n "$SSH_CLIENT$SSH2_CLIENT$SSH_TTY"
        set_color $__fish_prompt_color_dim
        echo -n (whoami)@(hostname -s)
        set_color normal
    end
end
