#!/bin/bash
PLIST="$HOME/Library/LaunchAgents/com.bhargav.shanshuiwallpaper.plist"
mkdir -p "$HOME/Library/LaunchAgents"

cat << PLIST_EOF > "$PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.bhargav.shanshuiwallpaper</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>-a</string>
        <string>$HOME/Applications/ShanShuiWallpaper.app</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLIST_EOF

launchctl load "$PLIST" 2>/dev/null || true
echo "Enabled! Shan Shui Wallpaper will now start automatically whenever you log in."
