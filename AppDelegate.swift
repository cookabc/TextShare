import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var heartbeatTimer: Timer?

    // 日志功能
    private func log(_ message: String) {
        let timestamp = DateFormatter()
        timestamp.dateFormat = "HH:mm:ss"
        print("[\(timestamp.string(from: Date()))] \(message)")
        fflush(stdout)  // 立即输出到终端
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("应用启动完成")

        // 初始化配置
        FontConfig.shared.loadConfig()
        log("字体配置加载完成")

        // 设置各个管理器
        StatusBarManager.shared.setup(onGenerateImage: { [weak self] in
            self?.generateImage()
        })
        log("菜单栏图标设置完成")

        HotkeyManager.shared.setup(onHotkeyPressed: { [weak self] in
            self?.generateImage()
        })
        log("全局快捷键设置完成")

        // 不创建主窗口，只作为后台应用运行
        log("应用初始化完成，开始运行")

        // 设置应用不自动退出
        NSApp.setActivationPolicy(.accessory)

        // 创建一个计时器来保持应用活跃
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            // 每10秒记录一次心跳
            self?.log("应用心跳 - 确认应用仍在运行")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        log("应用即将退出")
        // 清理资源
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil

        // 清理各个管理器
        StatusBarManager.shared.cleanup()
        HotkeyManager.shared.cleanup()
        PopupWindowManager.shared.cleanup()

        log("所有资源已清理")
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        log("系统请求终止应用")
        return .terminateNow
    }

    @objc private func generateImage() {
        log("快捷键触发，开始生成分享图")

        let clipboard = NSPasteboard.general
        guard let text = clipboard.string(forType: .string), !text.isEmpty else {
            log("剪贴板中没有文本内容")
            showClipboardEmptyNotification()
            return
        }

        log("从剪贴板获取到文本: \(text.prefix(50))...")
        log("开始生成图片")

        if let image = ImageGenerator.shared.generateImage(from: text, theme: .light) {
            log("图片生成成功，尺寸: \(image.size)")

            // 将图片复制到剪贴板
            let imagePasteboard = NSPasteboard.general
            imagePasteboard.clearContents()
            let success = imagePasteboard.writeObjects([image])
            log("图片复制到剪贴板: \(success ? "成功" : "失败")")

            // 显示预览窗口
            PopupWindowManager.shared.showPopup(with: image, text: text)
        } else {
            log("图片生成失败")
        }
    }

    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            PopupWindowManager.shared.windowWillClose(window)
        }
    }

    private func showClipboardEmptyNotification() {
        let alert = NSAlert()
        alert.messageText = "剪贴板为空"
        alert.informativeText = "请先复制一些文本，然后按 ⌘⇧C 生成分享图。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")

        // 显示通知但不阻塞主线程
        DispatchQueue.main.async {
            alert.runModal()
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