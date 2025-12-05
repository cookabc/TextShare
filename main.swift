import Cocoa

// 创建最基本的NSApplication
let app = NSApplication.shared

// 创建应用代理并设置
let appDelegate = AppDelegate()
app.delegate = appDelegate

// 激活应用
app.activate(ignoringOtherApps: true)

// 运行应用
app.run()