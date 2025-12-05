import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popupWindow: PopupWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusBarItem()
        setupGlobalHotKey()
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
            showAlert(message: "剪贴板中没有文本内容")
            return
        }

        if popupWindow != nil {
            popupWindow?.close()
        }

        let generator = ImageGenerator()
        if let image = generator.generateImage(from: text, theme: .light) {
            popupWindow = PopupWindow(image: image, text: text)
            popupWindow?.makeKeyAndOrderFront(nil)

            // 将图片复制到剪贴板
            let imagePasteboard = NSPasteboard.general
            imagePasteboard.clearContents()
            imagePasteboard.writeObjects([image])

            // 3秒后自动关闭窗口
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.popupWindow?.close()
                self.popupWindow = nil
            }
        }
    }

    private func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}