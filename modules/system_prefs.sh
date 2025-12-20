#!/bin/bash

# macOS Configuration Script
# Usage: Save as .sh file, chmod +x, and run with sudo for system-level preferences

set -e # Exit immediately if any command fails

SCREENSHOTS_LOCATION="$HOME/Desktop/screenshots"

# Mapping of preference domains to their respective processes
declare -A DOMAIN_PROCESS_MAP=(
    ["com.apple.finder"]="Finder"
    ["com.apple.dock"]="Dock"
    ["com.apple.controlcenter"]="ControlCenter"
    ["com.apple.systempreferences"]="System Preferences"
    ["com.apple.ActivityMonitor"]="Activity Monitor"
)

# Set to collect domains that need restarting
declare -A DOMAINS_TO_RESTART

# Configuration Settings Array
# Format: "DOMAIN KEY VALUE TYPE"
CONFIG_SETTINGS=(
    # Enable tap to click
    "com.apple.AppleMultitouchTrackpad Clicking true bool"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking true bool"
    "NSGlobalDomain com.apple.mouse.tapBehavior 1 int"

    # Enable secondary click (right click with two fingers)
    "com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick true bool"
    "NSGlobalDomain com.apple.trackpad.enableSecondaryClick true bool"

    # FILE SYSTEM & FINDER
    "com.apple.finder AppleShowAllFiles false bool"               # keep hidden files, hidden
    "com.apple.finder _FXShowPosixPathInTitle true bool"         # Display full POSIX path as window title
    "com.apple.finder _FXSortFoldersFirs true bool"              # Keep folders on top when sorting by name
    "com.apple.finder _FXSortFoldersFirstOnDesktop true bool"    # Keep folders on top when sorting desktop by name
    "com.apple.finder FXPreferredViewStyle Nlsv string"          # Use list view in all Finder windows by default, other view modes: `icnv`, `clmv`, `glyv`
    "com.apple.finder FXDefaultSearchScope SCcf string"          # search the current folder by default
    "com.apple.finder ShowPathbar true bool"                     # Show path bar
    "com.apple.finder ShowStatusBar true bool"                   # Show status bar
    "NSGlobalDomain AppleShowAllExtensions true bool"            # show file extensions
    "NSGlobalDomain NSTableViewDefaultSizeMode 2 int"            # Set sidebar icon size to medium
    "NSGlobalDomain AppleShowScrollBars Always string"           # Always show scrollbars
    "com.apple.finder FXEnableExtensionChangeWarning false bool" # Disable the warning when changing a file extension
    # Expand save panel by default
    "NSGlobalDomain NSNavPanelExpandedStateForSaveMode true bool"
    "NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 true bool"
    "com.apple.finder QLEnableTextSelection true bool" # allow text selection in Quick Look

    # Enable spring loading for directories
    "NSGlobalDomain com.apple.springing.enabled false bool"

    # Remove the spring loading delay for directories
    "NSGlobalDomain com.apple.springing.delay 0 float"

    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    "com.apple.NetworkBrowser BrowseAllInterfaces true bool"

    "NSGlobalDomain NSDocumentSaveNewDocumentsToCloud false bool" # Save to disk (not to iCloud) by default
    # Disable the "Are you sure you want to open this application?" dialog
    "com.apple.LaunchServices LSQuarantine false bool"

    # Set Help Viewer windows to non-floating mode
    "com.apple.helpviewer DevMode true bool"

    # Expand print panel by default
    "NSGlobalDomain PMPrintingExpandedStateForPrint true bool"
    "NSGlobalDomain PMPrintingExpandedStateForPrint2 true bool"

    # Avoid creating .DS_Store files on network or USB volumes
    "com.apple.desktopservices DSDontWriteNetworkStores true bool"
    "com.apple.desktopservices DSDontWriteUSBStores true bool"

    # Show icons for hard drives, servers, and removable media on the desktop
    "com.apple.finder ShowExternalHardDrivesOnDesktop true bool"
    "com.apple.finder ShowHardDrivesOnDesktop true bool"
    "com.apple.finder ShowMountedServersOnDesktop true bool"
    "com.apple.finder ShowRemovableMediaOnDesktop true bool"

    # SYSTEM BEHAVIOR
    # Disable the "Are you sure you want to open this application?" dialog
    "com.apple.LaunchServices LSQuarantine false bool"
    "NSGlobalDomain NSAutomaticWindowAnimationsEnabled true bool" # Disable window animations
    # Use scroll gesture with the Ctrl (^) modifier key to zoom
    # Requires full disk access
    "com.apple.universalaccess closeViewScrollWheelToggle true bool"
    # Disable automatic termination of inactive apps
    "NSGlobalDomain NSDisableAutomaticTermination true bool"

    # KEYBOARD & INPUT
    "NSGlobalDomain KeyRepeat 2 int"                                 # Fast keyboard repeat rate (minimum)
    "NSGlobalDomain InitialKeyRepeat 15 int"                         # Short initial repeat delay
    "NSGlobalDomain NSAutomaticCapitalizationEnabled false bool"     # Disable automatic capitalization
    "NSGlobalDomain NSAutomaticDashSubstitutionEnabled false bool"   # Disable smart dashes
    "NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled false bool" # Disable automatic period substitution
    "NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled false bool"  # Disable smart quotes
    "NSGlobalDomain NSAutomaticSpellingCorrectionEnabled false bool" # Disable auto-correct
    "NSGlobalDomain AppleKeyboardUIMode 3 int"                       # Enable full keyboard access for all controls

    # SCREEN & VISUALS
    "NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically true bool" # Auto dark mode
    "com.apple.screensaver askForPassword 1 int"                        # Require password after screensaver

    # DOCK & MENU BAR
    "com.apple.dock orientation bottom string"                         # Set Dock position to bottom
    "com.apple.dock autohide false bool"                               # Always show dock
    "com.apple.dock tilesize 56 int"                                   # Smaller Dock icons
    "com.apple.dock magnification true bool"                           # magnification
    "com.apple.dock largesize 40 int"                                  # magnification size
    "com.apple.dock mineffect genie string"                            # dock minimize animation
    "com.apple.dock minimize-to-application true bool"                 # Minimize windows into their application's icon
    "com.apple.dock show-recents false bool"                           # Don't show recent applications in Dock
    "com.apple.dock launchanim false bool"                             # Don't animate opening applications from the Dock
    "com.apple.dock expose-animation-duration 0.1 float"               # Speed up Mission Control animations
    "com.apple.dock mru-spaces false bool"                             # Don't automatically rearrange Spaces based on most recent use
    "com.apple.dock enable-spring-load-actions-on-all-items true bool" # Enable spring loading for all Dock items
    "com.apple.dashboard mcx-disabled true bool"                       # Disable Dashboard
    "com.apple.dock showhidden true bool"                              # Make Dock icons of hidden applications translucent
    "com.apple.dock hide-mirror true bool"                             # Make Dock more transparent
    "com.apple.dock orientation right string"                         # Set Dock position to right

    # Screenshots
    "com.apple.screencapture location ${SCREENSHOTS_LOCATION} string" # change screenshot save location
    "com.apple.screencapture type jpg string"                         # Set screenshot format
    "com.apple.screencapture disable-shadow true bool"                # Disable shadow in screenshots

    # Terminal
    "com.apple.terminal StringEncodings 4 array" # Only use UTF-8 in Terminal.app
    # Enable "focus follows mouse" for Terminal.app and all X11 apps
    "com.apple.terminal FocusFollowsMouse true bool"
    "org.x.X11 wm_ffm true bool"

    # Display
    "NSGlobalDomain AppleFontSmoothing 2 int" # Enable subpixel font rendering on non-Apple LCDs

    # Activity Monitor
    "com.apple.ActivityMonitor OpenMainWindow true bool"   # Show the main window when launching Activity Monitor
    "com.apple.ActivityMonitor IconType 5 int"             # Visualize CPU usage in the Activity Monitor Dock icon
    "com.apple.ActivityMonitor ShowCategory 0 int"         # Show all processes in Activity Monitor
    "com.apple.ActivityMonitor SortColumn CPUUsage string" # Sort Activity Monitor results by CPU usage
    "com.apple.ActivityMonitor SortDirection 0 int"
)

apply_setting() {
    local domain="$1"
    local key="$2"
    local value="$3"
    local type="$4"

    log_info "Applying setting: $domain $key = $value ($type)"

    # Handle system-level vs user-level preferences
    if [[ "$domain" == /* ]]; then
        sudo defaults write "$domain" "$key" "-$type" "$value"
    else
        defaults write "$domain" "$key" "-$type" "$value"
    fi

    # Mark domain for restart if it's in the process map
    if [[ -n "${DOMAIN_PROCESS_MAP[$domain]+x}" ]]; then
        DOMAINS_TO_RESTART["$domain"]=1
    fi
}

restart_processes() {
    log_info "Restarting affected processes..."

    # Restart each unique process only once
    declare -A PROCESSES_RESTARTED
    for domain in "${!DOMAINS_TO_RESTART[@]}"; do
        local process="${DOMAIN_PROCESS_MAP[$domain]}"
        if [[ -z "${PROCESSES_RESTARTED[$process]+x}" ]]; then
            log_info "Restarting $process..."
            killall "$process" >/dev/null 2>&1 || true
            PROCESSES_RESTARTED["$process"]=1
        fi
    done
}

setup_system_prefs() {
    # Create screenshots directory if it doesn't exist
    mkdir -p "$SCREENSHOTS_LOCATION"

    # Apply all configurations
    for entry in "${CONFIG_SETTINGS[@]}"; do
        IFS=" " read -r domain key value type <<<"$entry"
        apply_setting "$domain" "$key" "$value" "$type"
    done

    # Menu bar: hide the Time Machine, and User icons
    for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
        defaults write "${domain}" dontAutoLoad -array \
            "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
            "/System/Library/CoreServices/Menu Extras/User.menu"
    done
    defaults write com.apple.systemuiserver menuExtras -array \
        "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
        "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
        "/System/Library/CoreServices/Menu Extras/Battery.menu" \
        "/System/Library/CoreServices/Menu Extras/Clock.menu"

    # Restart automatically if the computer freezes
    # sudo systemsetup -setrestartfreeze on

    # Show the ~/Library folder
    chflags nohidden ~/Library

    # Expand the following File Info panes:
    # "General", "Open with", and "Sharing & Permissions"
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true

    # Menu bar
    # see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
    defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM h:mm:ss a"

    # Restart processes after all changes
    restart_processes

    # Final system refresh
    killall SystemUIServer >/dev/null 2>&1 || true
    killall cfprefsd >/dev/null 2>&1 || true

    log_info "Configuration complete!"
    log_info "Some changes may require restart or re-login to take effect."
}
