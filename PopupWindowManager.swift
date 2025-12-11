import Cocoa

class PopupWindowManager {
    static let shared = PopupWindowManager()

    private var currentPopupWindow: PopupWindow?
    private var autoCloseTimer: Timer?

    private init() {}

    // 日志功能
    private func log(_ message: String) {
        let timestamp = DateFormatter()
        timestamp.dateFormat = "HH:mm:ss"
        print("[PopupManager-\(timestamp.string(from: Date()))] \(message)")
        fflush(stdout)
    }

    func showPopup(with image: NSImage, text: String) {
        log("开始显示预览窗口")

        // 取消之前的自动关闭计时器
        autoCloseTimer?.invalidate()
        autoCloseTimer = nil

        currentPopupWindow = PopupWindow(image: image, text: text)
        log("创建预览窗口")
        currentPopupWindow?.makeKeyAndOrderFront(nil)
        log("显示预览窗口")

        // 3秒后自动关闭窗口
        autoCloseTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.log("开始关闭预览窗口")
            self?.currentPopupWindow?.safeClose()
            self?.currentPopupWindow = nil
            self?.autoCloseTimer = nil
            self?.log("预览窗口已关闭")
        }
    }

    func windowWillClose(_ window: NSWindow) {
        if window == currentPopupWindow {
            log("用户手动关闭预览窗口")
            autoCloseTimer?.invalidate()
            autoCloseTimer = nil
            currentPopupWindow = nil
        }
    }

    func cleanup() {
        autoCloseTimer?.invalidate()
        autoCloseTimer = nil
        currentPopupWindow?.close()
        currentPopupWindow = nil
    }
}