import Cocoa

class HotkeyManager {
    static let shared = HotkeyManager()

    private var monitor: Any?
    private var onHotkeyPressed: (() -> Void)?

    private init() {}

    func setup(onHotkeyPressed: @escaping () -> Void) {
        self.onHotkeyPressed = onHotkeyPressed

        // 仅在应用内监听快捷键，避免权限问题
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 8 { // 8是C键的键码
                DispatchQueue.main.async {
                    onHotkeyPressed()
                }
            }
            return event
        }
    }

    func cleanup() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}