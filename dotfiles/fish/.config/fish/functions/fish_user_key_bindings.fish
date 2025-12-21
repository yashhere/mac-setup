function fish_user_key_bindings
    # Natural text editing keybindings
    # These work with iTerm2 natural text editing preset

    # Cmd+Left Arrow -> Move to beginning of line (Ctrl+A)
    bind \ca beginning-of-line

    # Cmd+Right Arrow -> Move to end of line (Ctrl+E)
    bind \ce end-of-line

    # Option+Left Arrow -> Move backward one word (Esc+b)
    bind \eb backward-word

    # Option+Right Arrow -> Move forward one word (Esc+f)
    bind \ef forward-word

    # Cmd+Delete -> Delete to beginning of line (Ctrl+U)
    bind \cu backward-kill-line

    # Option+Delete -> Delete word backward (Ctrl+W)
    bind \cw backward-kill-word

    # Additional useful keybindings
    # Ctrl+K -> Delete to end of line
    bind \ck kill-line

    # Option+D -> Delete word forward
    bind \ed kill-word
end
