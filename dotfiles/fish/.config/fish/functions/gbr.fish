function gbr --description 'Interactive branch delete with fzf'
    if not command -v fzf &>/dev/null
        echo "fzf is not installed. Install it with: brew install fzf"
        return 1
    end

    # Get list of branches excluding current branch
    set branches (git branch | grep -v '^\*' | sed 's/^[[:space:]]*//')

    if test (count $branches) -eq 0
        echo "No branches to delete"
        return 0
    end

    # Select branches to delete with fzf (multi-select enabled)
    set selected (printf '%s\n' $branches | fzf --multi --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {}' --header 'Select branches to delete (TAB to select multiple)')

    if test -n "$selected"
        echo "Deleting branches:"
        for branch in $selected
            echo "  - $branch"
            git branch -d $branch
        end
    else
        echo "No branches selected"
    end
end
