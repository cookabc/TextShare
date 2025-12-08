import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem?
    private var currentPopupWindow: PopupWindow?
    private var autoCloseTimer: Timer?
    private let imageGenerator = ImageGenerator()

    // 日志功能
    private func log(_ message: String) {
        let timestamp = DateFormatter()
        timestamp.dateFormat = "HH:mm:ss"
        print("[\(timestamp.string(from: Date()))] \(message)")
        fflush(stdout)  // 立即输出到终端
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("应用启动完成")
        setupStatusBarItem()
        log("菜单栏图标设置完成")
        setupGlobalHotKey()
        log("全局快捷键设置完成")
        // 不创建主窗口，只作为后台应用运行
        log("应用初始化完成，开始运行")

        // 设置应用不自动退出
        NSApp.setActivationPolicy(.accessory)

        // 创建一个计时器来保持应用活跃
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            // 每10秒记录一次心跳
            self?.log("应用心跳 - 确认应用仍在运行")
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        log("应用即将退出")
        // 清理资源
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        log("系统请求终止应用")
        return .terminateNow
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
        log("快捷键触发，开始生成分享图")

        // 取消之前的自动关闭计时器
        autoCloseTimer?.invalidate()
        autoCloseTimer = nil

        let clipboard = NSPasteboard.general
        guard let text = clipboard.string(forType: .string), !text.isEmpty else {
            log("剪贴板中没有文本内容")
            return  // 简单返回，不显示警告
        }

        log("从剪贴板获取到文本: \(text.prefix(50))...")
        log("开始生成图片")

        if let image = imageGenerator.generateImage(from: text, theme: .light) {
            log("图片生成成功，尺寸: \(image.size)")

            currentPopupWindow = PopupWindow(image: image, text: text)
            currentPopupWindow?.delegate = self
            log("创建预览窗口")
            currentPopupWindow?.makeKeyAndOrderFront(nil)
            log("显示预览窗口")

            // 将图片复制到剪贴板
            let imagePasteboard = NSPasteboard.general
            imagePasteboard.clearContents()
            let success = imagePasteboard.writeObjects([image])
            log("图片复制到剪贴板: \(success ? "成功" : "失败")")

            // 3秒后自动关闭窗口
            autoCloseTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.log("开始关闭预览窗口")
                self?.currentPopupWindow?.safeClose()
                self?.currentPopupWindow = nil
                self?.autoCloseTimer = nil
                self?.log("预览窗口已关闭")
            }
        } else {
            log("图片生成失败")
        }
    }

    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == currentPopupWindow {
            log("用户手动关闭预览窗口")
            autoCloseTimer?.invalidate()
            autoCloseTimer = nil
            currentPopupWindow = nil
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