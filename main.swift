import Cocoa

// 创建NSApplication实例
let app = NSApplication.shared
app.setActivationPolicy(.regular)  // 在Dock中显示

// 创建应用代理
let delegate = AppDelegate()
app.delegate = delegate

// 创建主窗口
let window = NSWindow()
window.title = "文字分享图生成器"
window.setContentSize(NSSize(width: 400, height: 200))
window.styleMask = [.titled, .closable, .resizable]
window.center()
window.isReleasedWhenClosed = false

// 创建主窗口内容
let contentView = NSView()
window.contentView = contentView

// 添加说明文本
let infoLabel = NSTextField(labelWithString: "使用说明：\n\n1. 复制任意文本 (⌘C)\n2. 按 ⌘⇧C 生成分享图\n3. 图片自动复制到剪贴板\n\n点击菜单栏图标 📝 查看预览")
infoLabel.alignment = .center
infoLabel.isEditable = false
infoLabel.isBordered = false
infoLabel.backgroundColor = NSColor.clear
infoLabel.translatesAutoresizingMaskIntoConstraints = false
contentView.addSubview(infoLabel)

// 设置约束
infoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
infoLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
infoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20).isActive = true
infoLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20).isActive = true

// 显示窗口
window.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)

// 运行应用主循环
app.run()