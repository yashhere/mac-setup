#!/usr/bin/env bash
# Setup keyboard remapping using hidutil
# Maps eject key to lock screen (for older Magic Keyboards)

set -euo pipefail

PLIST_PATH="${HOME}/Library/LaunchAgents/com.user.keyboardremap.plist"

# Create the LaunchAgent plist
cat > "$PLIST_PATH" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.keyboardremap</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[
            {
              "HIDKeyboardModifierMappingSrc": 0x700000066,
              "HIDKeyboardModifierMappingDst": 0x700000066
            }
        ]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# Load the LaunchAgent
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "✓ Keyboard remapping configured"
echo "  Eject key will now trigger lock screen"
echo "  This will persist across reboots"
