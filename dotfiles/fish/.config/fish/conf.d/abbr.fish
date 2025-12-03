# cspell: disable
if status is-interactive
    # General
    abbr --add l ls
    abbr --add ll 'ls -la'
    abbr --add la 'ls -a'
    abbr --add ping 'ping -c 3'
    abbr --add s sudo
    abbr --add c clear
    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
    abbr --add .... 'cd ../../..'

    # Lazygit
    abbr --add lg lazygit

    # Modern CLI tools
    abbr --add cat bat
    abbr --add find fd
    abbr --add grep rg

    # Directory navigation (zoxide replaces cd)
    abbr --add cdi 'cdi'  # Interactive directory picker

    # Editors
    abbr --add v nvim
    abbr --add vi nvim

    # Homebrew
    abbr --add bu 'brew update && brew upgrade'
    abbr --add bc 'brew cleanup'
end
