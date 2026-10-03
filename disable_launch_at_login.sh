#!/bin/bash
PLIST="$HOME/Library/LaunchAgents/com.bhargav.shanshuiwallpaper.plist"
if [ -f "$PLIST" ]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm -f "$PLIST"
    echo "Disabled launch at login."
else
    echo "Launch at login was not enabled."
fi
