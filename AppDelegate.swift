import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popupWindow: PopupWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusBarItem()
        setupGlobalHotKey()
        // 不创建主窗口，只作为后台应用运行
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // 清理资源
    }

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "📝"
        statusItem?.button?.toolTip = "文字分享图生成器"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "生成分享图 (⌘⇧C)", action: #selector(generateImage), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

  private func setupGlobalHotKey() {
        // 仅在应用内监听快捷键，避免权限问题
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 8 { // 8是C键的键码
                DispatchQueue.main.async {
                    self.generateImage(nil)
                }
            }
            return event
        }
    }

    @objc private func generateImage(_ sender: Any?) {
        let clipboard = NSPasteboard.general
        guard let text = clipboard.string(forType: .string), !text.isEmpty else {
            return  // 简单返回，不显示警告
        }

        let generator = ImageGenerator()
        if let image = generator.generateImage(from: text, theme: .light) {
            let popupWindow = PopupWindow(image: image, text: text)
            popupWindow.makeKeyAndOrderFront(nil)

            // 将图片复制到剪贴板
            let imagePasteboard = NSPasteboard.general
            imagePasteboard.clearContents()
            imagePasteboard.writeObjects([image])

            // 3秒后自动关闭窗口
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                popupWindow.close()
            }
        }
    }

    private func createMainWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 150),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "文字分享图生成器"
        window.center()
        window.isReleasedWhenClosed = false

        let contentView = NSView()
        window.contentView = contentView

        let label = NSTextField(labelWithString: "使用说明：\n复制文本后按 ⌘⇧C 生成分享图")
        label.alignment = .center
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = NSColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20).isActive = true

        window.makeKeyAndOrderFront(nil)
    }
}