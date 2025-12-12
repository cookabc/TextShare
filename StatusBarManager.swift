import Cocoa

class StatusBarManager {
    static let shared = StatusBarManager()

    private var statusItem: NSStatusItem?
    private var onGenerateImage: (() -> Void)?
    private var settingsWindow: SettingsWindow?

    private init() {}

    func setup(onGenerateImage: @escaping () -> Void) {
        self.onGenerateImage = onGenerateImage

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "📝"
        statusItem?.button?.toolTip = "文字分享图生成器"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "生成分享图 (⌘⇧C)", action: #selector(generateImage), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "设置", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func generateImage() {
        onGenerateImage?()
    }

    @objc private func showSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindow(
                contentRect: NSRect.zero,
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
        }

        settingsWindow?.center()
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func cleanup() {
        settingsWindow?.close()
        settingsWindow = nil
        statusItem = nil
    }
}