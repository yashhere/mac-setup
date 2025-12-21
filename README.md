# Mac Setup

Automated macOS development environment setup using Homebrew, GNU Stow, and dotfiles.

## What This Does

- Installs Homebrew packages defined in `Brewfile`
- Sets up dotfiles for 28+ tools using GNU Stow
- Configures iTerm2, Fish, Tmux, Git, Neovim, and more
- Applies macOS system preferences

## Quick Start

1. Clone this repo:
   ```bash
   git clone https://github.com/yourusername/mac-setup.git
   cd mac-setup
   ```

2. Run the setup:
   ```bash
   ./setup.sh
   ```

   On first run, it will create `.env` from `.env.example`. Review and re-run.

## Running Specific Modules

```bash
./setup.sh --module dotfiles      # Just install dotfiles
./setup.sh --module configuration # Just configure apps
```

## Dotfiles Structure

Each directory in `dotfiles/` is a Stow package:
- `dotfiles/fish/` → `~/.config/fish/`
- `dotfiles/git/` → `~/.gitconfig`
- `dotfiles/tmux/` → `~/.config/tmux/`

To skip packages, add to `SKIP_STOW_PACKAGES` in `.env`.

## iTerm2 Configuration

iTerm2 settings are managed via JSON Dynamic Profiles in `dotfiles/iterm/profiles/`.

To export new settings:
1. iTerm2 → Preferences → Profiles → Other Actions → Save Profile as JSON
2. The exported file needs to be wrapped in a `"Profiles"` array:
   ```json
   {
     "Profiles": [
       { ...your profile settings... }
     ]
   }
   ```
3. Save to `dotfiles/iterm/profiles/YourProfileName.json`
4. Re-run `./setup.sh --module configuration`

The profile will be automatically copied to `~/Library/Application Support/iTerm2/DynamicProfiles/`.

## Customization

Edit `.env` to customize:
- `COMPUTER_NAME` - Your machine name
- `SKIP_STOW_PACKAGES` - Dotfiles to skip
- `SCREENSHOTS_LOCATION` - Where screenshots are saved

## Updating

Re-run `./setup.sh` to update. It's designed to be re-runnable.
