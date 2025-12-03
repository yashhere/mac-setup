# Key bindings for iTerm2 on macOS
# These handle the escape sequences that iTerm2 sends for navigation keys

if status is-interactive
    # Word navigation (Option+Arrow keys)
    # These work when iTerm2 has "Left/Right Option key sends Esc+"
    bind \eb backward-word      # Option+Left
    bind \ef forward-word       # Option+Right

    # Alternative sequences that some terminals send
    bind \e\[1\;9D backward-word  # Option+Left (iTerm2 default)
    bind \e\[1\;9C forward-word   # Option+Right (iTerm2 default)
    bind \e\[1\;3D backward-word  # Alt+Left alternative
    bind \e\[1\;3C forward-word   # Alt+Right alternative

    # Line navigation (Cmd+Arrow or Home/End)
    bind \ca beginning-of-line   # Ctrl+A (standard)
    bind \ce end-of-line         # Ctrl+E (standard)
    bind \e\[H beginning-of-line # Home key
    bind \e\[F end-of-line       # End key
    bind \e\[1\~ beginning-of-line # Home alternative
    bind \e\[4\~ end-of-line     # End alternative

    # For iTerm2 Cmd+Left/Right (requires iTerm2 key mapping)
    # Map Cmd+Left to send escape sequence: \x01 (Ctrl+A)
    # Map Cmd+Right to send escape sequence: \x05 (Ctrl+E)
    bind \x01 beginning-of-line
    bind \x05 end-of-line

    # Delete word (Option+Backspace)
    bind \e\x7f backward-kill-word  # Option+Backspace
    bind \e\b backward-kill-word    # Alternative

    # Delete to end of line (Cmd+Backspace)
    bind \cU backward-kill-line     # Ctrl+U (standard)
end
