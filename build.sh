#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_DIR="$DIR/ShanShuiWallpaper.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RESOURCES_DIR="$APP_DIR/Contents/Resources"

echo "🏔️ Building ShanShuiWallpaper.app..."

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy index.html inside the app bundle so it is 100% portable on any Mac
cp "$DIR/index.html" "$RESOURCES_DIR/index.html"

# Compile Swift app
swiftc -O "$DIR/main.swift" -o "$MACOS_DIR/ShanShuiWallpaper"

# Copy Info.plist
cat << 'PLIST_EOF' > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>ShanShuiWallpaper</string>
    <key>CFBundleIdentifier</key>
    <string>com.bhargav.shanshuiwallpaper</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Shan Shui Wallpaper</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1</string>
    <key>CFBundleVersion</key>
    <string>2</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST_EOF

# Ad-hoc sign so macOS Gatekeeper allows double-clicking without errors
codesign --force --deep --sign - "$APP_DIR" 2>/dev/null || true

echo "✅ Build successful! Application ready at: $APP_DIR"
