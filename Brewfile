# vim:ft=ruby

# Brewfile: Defines applications and packages to be installed by Homebrew and Homebrew Cask.

# Taps: Add external repositories for formulae and casks.
# These extend Homebrew's package availability beyond the core packages.
tap "guumaster/tap"
tap "buo/cask-upgrade"

# Brew Packages: Command-line tools and utilities installed via `brew install`.

# --- Core Utilities ---
brew "coreutils"    # GNU File, Shell, and Text utilities - essential command line tools
brew "openssl@3"

# --- File and Text Utilities ---
brew "diffutils"
brew "findutils"    # Collection of GNU find, xargs, and locate
brew "gnu-sed"
brew "grep"
brew "moreutils"      # Install some other useful utilities like `sponge`.

# --- Shell and Terminal ---
brew "bash"          # Install a modern version of Bash.
brew "bash-completion2"
brew "btop"          # Resource monitor in terminal
brew "fish"
brew "htop"          # Interactive process viewer
brew "lsd"           # Next gen `ls` command
brew "neofetch"      # System information tool
brew "screen"
brew "tmux"          # Terminal multiplexer
brew "vim"           # Classic text editor
brew "neovim"        # Modern fork of vim

# --- Git Tools ---
brew "git"
brew "git-delta"     # Beautiful git diffs with syntax highlighting
brew "git-filter-repo" # Tool to rewrite git history
brew "gh"            # GitHub CLI tool
brew "lazygit"       # A better git UI
brew "stow"          # Symlink farm manager

# --- Development Tools ---
brew "mise"          # Version manager for multiple languages
brew "direnv"        # Environment switcher for directories
brew "gnupg"        # enable PGP-signing commits.
brew "make"
brew "pre-commit"    # Manage and run git hooks
brew "shellcheck"                      # diagnostics for shell sripts
brew "gcc"           # GNU compiler collection

# --- Networking Tools ---
brew "aria2"         # Download manager
brew "gping"         # Ping, but with a graph
brew "grpcurl"       # gRPC command line client
brew "httpie"        # Modern HTTP client (CLI)
brew "openssh"       # Includes ssh-copy-id utility
brew "wakeonlan"      # Wake-on-LAN command
brew "wget"
brew "guumaster/tap/hostctl"    # manage /etc/hosts like a pro

# --- System Tools ---
brew "imagemagick"   # Image manipulation tools
brew "pandoc"

# --- Search Tools ---
brew "ack"           # Grep-like text finder
brew "fd"            # Fast and user-friendly find alternative
brew "fzf"           # Fuzzy finder
brew "lnav"          # Curses-based tool for viewing and analyzing log files
brew "ripgrep"       # Fast grep alternative (rg)
brew "zoxide"        # Smarter cd command that learns your habits

# --- Misc Utilities ---
brew "bat"           # `cat` clone with syntax highlighting
brew "cheat"         # Display cheatsheets for command-line tools
brew "doggo"         # DNS lookup tool
brew "entr"          # Run arbitrary commands when files change
brew "ffmpeg"        # Multimedia framework
brew "glow" # Render markdown on the CLI
brew "jq"            # JSON processor
brew "yq"
brew "lazydocker"                           # a better docker UI
brew "tealdeer"      # tldr client - simplified man pages
brew "tree"          # Display directory tree
brew "superfile"     # fancy file manager for the terminal
brew "yt-dlp"     # youtube-dl fork with additional features and fixes
brew "mkcert"
brew "nss"
brew "tokei"

# AI tools

if OS.mac?
    # --- macOS Specific Brew Packages ---
    brew "trash"                         # rm, but put in the trash rather than completely delete

    # Cask Applications: macOS GUI applications installed via `brew install --cask`.

    # --- Fonts ---
    cask "font-hack-nerd-font"
    cask "font-hasklig"
    cask "font-jetbrains-mono-nerd-font"
    cask "font-symbols-only-nerd-font"
    cask "font-sauce-code-pro-nerd-font"
    cask "font-source-code-pro"

    # --- Utilities ---
    cask "stats"         # System monitoring in your menu bar
    cask "imageoptim"    # Image optimization tool
    cask "iterm2"        # Terminal emulator
    cask "ghostty"       # Terminal emulator
    cask "maccy"         # Clipboard manager
    cask "ollama"        # Run large language models locally
    cask "the-unarchiver" # Archive extraction utility
    cask "utm"           # Virtual machine manager
    cask "vmware-fusion"               # Virtualization software

    # --- Development Tools ---
    cask "postman"       # API platform
    cask "visual-studio-code" # Code editor

    # --- Quick Look Plugins ---
    cask "qlcolorcode"    # Syntax highlighting for code in Quick Look
    cask "qlmarkdown"     # Markdown preview in Quick Look
    cask "qlprettypatch"  # Patch file preview in Quick Look
    cask "qlstephen"      # Plain text preview in Quick Look
    cask "quicklook-csv"  # CSV preview in Quick Look
    cask "quicklook-json" # JSON preview in Quick Look

    # --- Media Players ---
    cask "iina"           # Modern video player
    cask "spotify"       # Music streaming service
    cask "vlc"           # Media player

    # --- Browsers ---
    cask "brave-browser"

    # --- Productivity/Office ---
    cask "obsidian"      # Note-taking and knowledge management
end
