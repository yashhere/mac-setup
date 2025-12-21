function tm --description 'Smart tmux session manager'
    if not command -v tmux &>/dev/null
        echo "tmux is not installed. Install it with: brew install tmux"
        return 1
    end

    # If inside tmux, just list sessions
    if test -n "$TMUX"
        tmux list-sessions
        return 0
    end

    # Get session name from argument or use fzf to select
    set session_name $argv[1]

    if test -z "$session_name"
        # If fzf is available, use it to select session
        if command -v fzf &>/dev/null
            set existing_sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)

            if test -n "$existing_sessions"
                set session_name (printf '%s\n' $existing_sessions | fzf --header 'Select tmux session (or Ctrl-C to create new)')
            end
        end

        # If still no session name, prompt for new one
        if test -z "$session_name"
            read -P "Enter session name: " session_name
        end
    end

    if test -z "$session_name"
        echo "No session name provided"
        return 1
    end

    # Create or attach to session
    if tmux has-session -t $session_name 2>/dev/null
        echo "Attaching to existing session: $session_name"
        tmux attach-session -t $session_name
    else
        echo "Creating new session: $session_name"
        tmux new-session -s $session_name
    end
end
