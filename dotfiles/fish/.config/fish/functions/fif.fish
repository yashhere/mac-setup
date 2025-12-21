function fif --description 'Find in files with fzf and open in editor'
    if not command -v rg &>/dev/null
        echo "ripgrep (rg) is not installed. Install it with: brew install ripgrep"
        return 1
    end

    if not command -v fzf &>/dev/null
        echo "fzf is not installed. Install it with: brew install fzf"
        return 1
    end

    # Search pattern
    set search_term $argv[1]

    if test -z "$search_term"
        echo "Usage: fif <search_term>"
        return 1
    end

    # Use ripgrep to find files, fzf to select, and open in editor
    set result (rg --line-number --color=always --no-heading $search_term | \
                fzf --ansi --delimiter : \
                    --preview 'bat --color=always --highlight-line {2} {1}' \
                    --preview-window '+{2}/2')

    if test -n "$result"
        set file (echo $result | cut -d: -f1)
        set line (echo $result | cut -d: -f2)
        $EDITOR +$line $file
    end
end
