import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var wallpaperWindows: [NSWindow] = []
    var webViews: [WKWebView] = []
    var controlPanelWindow: NSWindow?
    
    var isPaused = false
    var currentSpeed: Int = 3 // Default: Zen (3 px/s)
    var allowInteraction = false
    
    // UI elements in control panel
    var pauseButton: NSButton?
    var speedControl: NSSegmentedControl?
    var launchAtLoginCheckbox: NSButton?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusMenu()
        setupWindows()
        
        // Show control panel on first launch so user immediately knows how to control it
        showControlPanel()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showControlPanel()
        return true
    }

    // MARK: - HTML Resource Locator (100% Portable)
    func getHtmlURL() -> URL {
        // 1. Check inside App Bundle Resources
        if let bundleUrl = Bundle.main.url(forResource: "index", withExtension: "html") {
            return bundleUrl
        }
        
        // 2. Check next to the App Bundle
        let adjacentUrl = Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("index.html")
        if FileManager.default.fileExists(atPath: adjacentUrl.path) {
            return adjacentUrl
        }
        
        // 3. Check current folder / Downloads / home
        let paths = [
            FileManager.default.currentDirectoryPath + "/index.html",
            NSHomeDirectory() + "/Downloads/My Codes/wallpaper/index.html",
            NSHomeDirectory() + "/Downloads/codes/wallpaper/index.html",
            NSHomeDirectory() + "/Downloads/wallpaper/index.html",
            NSHomeDirectory() + "/shan-shui-inf/index.html"
        ]
        for p in paths {
            if FileManager.default.fileExists(atPath: p) {
                return URL(fileURLWithPath: p)
            }
        }
        
        return adjacentUrl
    }

    // MARK: - Menu Bar Setup
    func setupStatusMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "🏔️ Shan Shui"
            button.toolTip = "Shan Shui Live Wallpaper - Click to adjust speed"
        }

        buildMenu()
    }

    func buildMenu() {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "🏔️ Shan Shui Live Wallpaper", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(NSMenuItem.separator())

        // Speeds directly in main menu for instant access!
        let speedHeader = NSMenuItem(title: "Drift Speed:", action: nil, keyEquivalent: "")
        speedHeader.isEnabled = false
        menu.addItem(speedHeader)

        let speeds: [(String, Int)] = [
            ("  🧘 Zen (3 px/s - Meditative)", 3),
            ("  🍃 Calm (6 px/s - Relaxed)", 6),
            ("  🌊 Gentle (12 px/s - Subtle)", 12),
            ("  ⚡ Flow (24 px/s - Active)", 24)
        ]
        for (label, spd) in speeds {
            let item = NSMenuItem(title: label, action: #selector(changeSpeedFromMenu(_:)), keyEquivalent: "")
            item.target = self
            item.tag = spd
            item.state = (spd == currentSpeed) ? .on : .off
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        let pauseItem = NSMenuItem(
            title: isPaused ? "▶ Resume Scrolling" : "⏸ Pause Scrolling",
            action: #selector(togglePause),
            keyEquivalent: "p"
        )
        pauseItem.target = self
        menu.addItem(pauseItem)

        let newLandscapeItem = NSMenuItem(
            title: "🎲 New Landscape (Random Seed)",
            action: #selector(newLandscape),
            keyEquivalent: "r"
        )
        newLandscapeItem.target = self
        menu.addItem(newLandscapeItem)

        let reverseItem = NSMenuItem(
            title: "⇄ Reverse Drift Direction",
            action: #selector(toggleDirection),
            keyEquivalent: "d"
        )
        reverseItem.target = self
        menu.addItem(reverseItem)

        menu.addItem(NSMenuItem.separator())

        let panelItem = NSMenuItem(
            title: "⚙ Control Panel...",
            action: #selector(showControlPanel),
            keyEquivalent: ","
        )
        panelItem.target = self
        menu.addItem(panelItem)

        let openBrowserItem = NSMenuItem(
            title: "🌐 Open in Web Browser",
            action: #selector(openInBrowser),
            keyEquivalent: "b"
        )
        openBrowserItem.target = self
        menu.addItem(openBrowserItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit Shan Shui Wallpaper",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Native Wallpaper Windows
    func setupWindows() {
        for window in wallpaperWindows {
            window.close()
        }
        wallpaperWindows.removeAll()
        webViews.removeAll()

        let htmlURL = getHtmlURL()

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )

            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.isOpaque = true
            window.backgroundColor = NSColor(red: 0.97, green: 0.96, blue: 0.92, alpha: 1.0)
            window.hasShadow = false
            window.ignoresMouseEvents = !allowInteraction

            let config = WKWebViewConfiguration()
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            config.setValue(true, forKey: "drawsBackground")

            let webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
            webView.autoresizingMask = [.width, .height]
            webView.setValue(false, forKey: "drawsBackground")

            var components = URLComponents(url: htmlURL, resolvingAgainstBaseURL: false) ?? URLComponents()
            components.queryItems = [
                URLQueryItem(name: "speed", value: "\(currentSpeed)"),
                URLQueryItem(name: "wallpaper", value: "1")
            ]
            let finalURL = components.url ?? htmlURL

            webView.loadFileURL(finalURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())

            window.contentView?.addSubview(webView)
            window.orderBack(nil)

            wallpaperWindows.append(window)
            webViews.append(webView)
        }
    }

    @objc func screenParametersChanged() {
        setupWindows()
    }

    // MARK: - Actions
    @objc func togglePause() {
        isPaused = !isPaused
        for webView in webViews {
            webView.evaluateJavaScript("togglePause()")
        }
        updateControlPanelUI()
        buildMenu()
    }

    @objc func newLandscape() {
        for webView in webViews {
            webView.evaluateJavaScript("newSeed()")
        }
    }

    @objc func toggleDirection() {
        for webView in webViews {
            webView.evaluateJavaScript("toggleDirection()")
        }
    }

    @objc func changeSpeedFromMenu(_ sender: NSMenuItem) {
        setSpeed(sender.tag)
    }

    func setSpeed(_ spd: Int) {
        currentSpeed = spd
        for webView in webViews {
            webView.evaluateJavaScript("setSpeed(\(currentSpeed))")
        }
        updateControlPanelUI()
        buildMenu()
    }

    @objc func openInBrowser() {
        let htmlURL = getHtmlURL()
        NSWorkspace.shared.open(htmlURL)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Beautiful Native Control Panel Window
    @objc func showControlPanel() {
        if let window = controlPanelWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let rect = NSRect(x: 0, y: 0, width: 440, height: 380)
        let window = NSWindow(
            contentRect: rect,
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Shan Shui Live Wallpaper"
        window.isReleasedWhenClosed = false

        let contentView = NSView(frame: rect)
        window.contentView = contentView

        // 1. Header Icon & Title
        let iconLabel = NSTextField(labelWithString: "🏔️")
        iconLabel.font = NSFont.systemFont(ofSize: 42)
        iconLabel.frame = NSRect(x: (440 - 50) / 2, y: 310, width: 50, height: 50)
        iconLabel.alignment = .center
        contentView.addSubview(iconLabel)

        let titleLabel = NSTextField(labelWithString: "Shan Shui Live Wallpaper")
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 20, y: 280, width: 400, height: 26)
        contentView.addSubview(titleLabel)

        let subtitleLabel = NSTextField(labelWithString: "Infinite Procedural Chinese Landscape • GPU Accelerated")
        subtitleLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.alignment = .center
        subtitleLabel.frame = NSRect(x: 20, y: 260, width: 400, height: 20)
        contentView.addSubview(subtitleLabel)

        // 2. Speed Selector
        let speedLabel = NSTextField(labelWithString: "SCROLL SPEED")
        speedLabel.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        speedLabel.textColor = .secondaryLabelColor
        speedLabel.frame = NSRect(x: 35, y: 225, width: 200, height: 16)
        contentView.addSubview(speedLabel)

        let speedSegments = NSSegmentedControl(labels: ["Zen (3px)", "Calm (6px)", "Gentle (12px)", "Flow (24px)"],
                                               trackingMode: .selectOne,
                                               target: self,
                                               action: #selector(speedSegmentChanged(_:)))
        speedSegments.frame = NSRect(x: 35, y: 195, width: 370, height: 28)
        contentView.addSubview(speedSegments)
        self.speedControl = speedSegments

        // 3. Play / Pause & New Landscape Buttons
        let pauseBtn = NSButton(title: isPaused ? "▶ Resume Scrolling" : "⏸ Pause Scrolling",
                                target: self,
                                action: #selector(togglePause))
        pauseBtn.bezelStyle = .rounded
        pauseBtn.frame = NSRect(x: 35, y: 145, width: 180, height: 32)
        contentView.addSubview(pauseBtn)
        self.pauseButton = pauseBtn

        let newLandscapeBtn = NSButton(title: "🎲 New Landscape",
                                       target: self,
                                       action: #selector(newLandscape))
        newLandscapeBtn.bezelStyle = .rounded
        newLandscapeBtn.frame = NSRect(x: 225, y: 145, width: 180, height: 32)
        contentView.addSubview(newLandscapeBtn)

        // 4. Direction & Browser buttons
        let dirBtn = NSButton(title: "⇄ Reverse Direction",
                              target: self,
                              action: #selector(toggleDirection))
        dirBtn.bezelStyle = .rounded
        dirBtn.frame = NSRect(x: 35, y: 105, width: 180, height: 32)
        contentView.addSubview(dirBtn)

        let browserBtn = NSButton(title: "🌐 View in Browser",
                                  target: self,
                                  action: #selector(openInBrowser))
        browserBtn.bezelStyle = .rounded
        browserBtn.frame = NSRect(x: 225, y: 105, width: 180, height: 32)
        contentView.addSubview(browserBtn)

        // 5. Start at Login Checkbox
        let loginCheck = NSButton(checkboxWithTitle: "Launch automatically when Mac starts",
                                  target: self,
                                  action: #selector(toggleLaunchAtLogin(_:)))
        loginCheck.frame = NSRect(x: 38, y: 65, width: 350, height: 20)
        loginCheck.state = isLaunchAtLoginEnabled() ? .on : .off
        contentView.addSubview(loginCheck)
        self.launchAtLoginCheckbox = loginCheck

        // 6. Footer Note
        let footer = NSTextField(labelWithString: "Tip: Controls are also accessible via the 🏔️ icon in your top menu bar.")
        footer.font = NSFont.systemFont(ofSize: 11)
        footer.textColor = .tertiaryLabelColor
        footer.alignment = .center
        footer.frame = NSRect(x: 20, y: 22, width: 400, height: 20)
        contentView.addSubview(footer)

        self.controlPanelWindow = window
        updateControlPanelUI()

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func updateControlPanelUI() {
        pauseButton?.title = isPaused ? "▶ Resume Scrolling" : "⏸ Pause Scrolling"
        if let sc = speedControl {
            switch currentSpeed {
            case 3: sc.selectedSegment = 0
            case 6: sc.selectedSegment = 1
            case 12: sc.selectedSegment = 2
            case 24: sc.selectedSegment = 3
            default: sc.selectedSegment = 0
            }
        }
    }

    @objc func speedSegmentChanged(_ sender: NSSegmentedControl) {
        let speeds = [3, 6, 12, 24]
        if sender.selectedSegment >= 0 && sender.selectedSegment < speeds.count {
            setSpeed(speeds[sender.selectedSegment])
        }
    }

    // MARK: - Launch At Login
    func isLaunchAtLoginEnabled() -> Bool {
        let plistPath = NSHomeDirectory() + "/Library/LaunchAgents/com.bhargav.shanshuiwallpaper.plist"
        return FileManager.default.fileExists(atPath: plistPath)
    }

    @objc func toggleLaunchAtLogin(_ sender: NSButton) {
        let plistPath = NSHomeDirectory() + "/Library/LaunchAgents/com.bhargav.shanshuiwallpaper.plist"
        if sender.state == .on {
            let appPath = Bundle.main.bundlePath
            let xml = """
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
                    <string>\(appPath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
            </dict>
            </plist>
            """
            try? xml.write(toFile: plistPath, atomically: true, encoding: .utf8)
        } else {
            try? FileManager.default.removeItem(atPath: plistPath)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular) // Allows window to receive focus and appear in App Switcher/Spotlight cleanly
app.run()
