import Cocoa

// 设置应用为GUI应用
let app = NSApplication.shared
app.setActivationPolicy(.regular)  // 在Dock中显示

// 创建主窗口
let window = NSWindow(
    contentRect: NSRect(x: 100, y: 100, width: 400, height: 200),
    styleMask: [.titled, .closable, .resizable],
    backing: .buffered,
    defer: false
)
window.title = "文字分享图生成器"
window.center()

// 创建主窗口内容
let contentView = NSView()
window.contentView = contentView

// 添加说明文本
let infoLabel = NSTextField(labelWithString: "使用说明：\n\n1. 复制任意文本 (⌘C)\n2. 按 ⌘⇧C 生成分享图\n3. 图片自动复制到剪贴板\n\n点击菜单栏图标 📝 查看预览")
infoLabel.alignment = .center
infoLabel.translatesAutoresizingMaskIntoConstraints = false
contentView.addSubview(infoLabel)

NSLayoutConstraint.activate([
    infoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
    infoLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    infoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
    infoLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
])

// 设置应用代理
let delegate = AppDelegate()
app.delegate = delegate

// 显示窗口并运行
window.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)
app.run()