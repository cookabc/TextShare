# 预览窗口实现详解

## 🖼️ PopupWindow 界面组件

`PopupWindow` 负责显示生成的图片预览，提供主题切换功能，并支持图片保存。作为用户与应用交互的主要界面，它设计简洁、响应迅速。

## 📋 类结构概览

```swift
class PopupWindow: NSWindow {
    // MARK: - Properties
    private var imageView: NSImageView!
    private var themeSelector: NSSegmentedControl!
    private var saveButton: NSButton!
    private var containerStackView: NSStackView!

    private var originalText: String
    private var currentTheme: Theme
    private var generator: ImageGenerator

    // MARK: - Initialization
    init(image: NSImage, text: String)
    private func setupUI(image: NSImage)

    // MARK: - Actions
    @objc private func themeChanged(_ sender: NSSegmentedControl)
    @objc private func saveImage(_ sender: NSButton)
    @objc private func windowWillClose(_ notification: Notification)

    // MARK: - Helpers
    func safeClose()
    func setImage(_ image: NSImage)
}
```

## 🏗️ 窗口初始化

### 初始化流程

```swift
init(image: NSImage, text: String) {
    // 1. 保存原始数据
    self.originalText = text
    self.currentTheme = .light
    self.generator = ImageGenerator()

    // 2. 计算窗口尺寸
    let windowWidth = min(800, image.size.width + 100)
    let windowHeight = image.size.height + 140  // 额外空间用于控件

    // 3. 调用父类初始化
    super.init(
        contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered,
        defer: false
    )

    // 4. 设置窗口属性
    setupWindowProperties()

    // 5. 设置界面
    setupUI(image)

    // 6. 监听关闭事件
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(windowWillClose(_:)),
        name: NSWindow.willCloseNotification,
        object: self
    )
}
```

### 窗口属性配置

```swift
private func setupWindowProperties() {
    // 1. 窗口标题
    title = "图片预览 - 文字分享图生成器"

    // 2. 窗口行为
    level = .floating  // 浮动在最前
    isMovableByWindowBackground = true  // 可拖动背景

    // 3. 窗口位置（居中显示）
    center()

    // 4. 最小尺寸
    minSize = NSSize(width: 400, height: 300)

    // 5. 窗口图标
    if let icon = NSImage(named: NSImage.folderName) {
        standardWindowButton(.closeButton)?.image = icon
    }
}
```

## 🎨 界面布局设计

### Auto Layout 布局实现

```swift
private func setupUI(image: NSImage) {
    // 1. 创建主容器
    let containerView = NSView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    contentView?.addSubview(containerView)

    // 2. 创建图片视图
    imageView = NSImageView(image: image)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.imageScaling = .scaleProportionallyUpOrDown
    imageView.wantsLayer = true
    imageView.layer?.borderWidth = 1
    imageView.layer?.borderColor = NSColor.lightGray.cgColor
    imageView.layer?.cornerRadius = 8
    containerView.addSubview(imageView)

    // 3. 创建控制容器
    let controlsContainer = NSView()
    controlsContainer.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(controlsContainer)

    // 4. 创建主题选择器
    setupThemeSelector(in: controlsContainer)

    // 5. 创建保存按钮
    setupSaveButton(in: controlsContainer)

    // 6. 设置约束
    setupConstraints(containerView: containerView,
                   controlsContainer: controlsContainer)
}
```

### 约束设置详解

```swift
private func setupConstraints(containerView: NSView,
                            controlsContainer: NSView) {
    // 容器约束
    NSLayoutConstraint.activate([
        containerView.leadingAnchor.constraint(equalTo: contentView!.leadingAnchor, constant: 20),
        containerView.trailingAnchor.constraint(equalTo: contentView!.trailingAnchor, constant: -20),
        containerView.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20),
        containerView.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20)
    ])

    // 图片视图约束
    NSLayoutConstraint.activate([
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 600)
    ])

    // 控制容器约束
    NSLayoutConstraint.activate([
        controlsContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        controlsContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        controlsContainer.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
        controlsContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        controlsContainer.heightAnchor.constraint(equalToConstant: 40)
    ])

    // 控制项约束
    NSLayoutConstraint.activate([
        themeSelector.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
        themeSelector.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
        themeSelector.widthAnchor.constraint(equalToConstant: 240),

        saveButton.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
        saveButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
        saveButton.widthAnchor.constraint(equalToConstant: 80)
    ])
}
```

## 🎚️ 主题选择器

### 主题选择器设置

```swift
private func setupThemeSelector(in containerView: NSView) {
    // 1. 创建分段控件
    themeSelector = NSSegmentedControl(labels: ["浅色", "深色", "渐变"],
                                     trackingMode: .selectOne,
                                     target: self,
                                     action: #selector(themeChanged(_:)))

    // 2. 设置默认选择
    themeSelector.selectedSegment = 0  // 默认选择浅色

    // 3. 设置样式
    themeSelector.segmentStyle = .rounded
    themeSelector.translatesAutoresizingMaskIntoConstraints = false

    // 4. 添加到父视图
    containerView.addSubview(themeSelector)
}
```

### 主题切换实现

```swift
@objc private func themeChanged(_ sender: NSSegmentedControl) {
    // 1. 确定新主题
    switch sender.selectedSegment {
    case 0:
        currentTheme = .light
    case 1:
        currentTheme = .dark
    case 2:
        currentTheme = .gradient
    default:
        currentTheme = .light
    }

    // 2. 重新生成图片
    guard let newImage = generator.generateImage(from: originalText, theme: currentTheme) else {
        print("图片生成失败")
        return
    }

    // 3. 更新显示
    setImage(newImage)

    // 4. 更新剪贴板
    updateClipboard(with: newImage)
}
```

### 动画效果（扩展）

```swift
// 添加主题切换动画
private func animateThemeChange(to newImage: NSImage) {
    NSAnimationContext.runAnimationGroup({ context in
        context.duration = 0.3
        context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // 淡出
        imageView.animator().alphaValue = 0.0
    }) {
        // 更新图片
        self.imageView.image = newImage

        // 淡入
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            self.imageView.animator().alphaValue = 1.0
        })
    }
}
```

## 💾 保存功能实现

### 保存按钮设置

```swift
private func setupSaveButton(in containerView: NSView) {
    // 1. 创建按钮
    saveButton = NSButton(title: "保存",
                         target: self,
                         action: #selector(saveImage(_:)))

    // 2. 设置按钮样式
    saveButton.bezelStyle = .rounded
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    saveButton.keyEquivalent = "s"  // 支持 Cmd+S 快捷键

    // 3. 添加到父视图
    containerView.addSubview(saveButton)
}
```

### 保存图片实现

```swift
@objc private func saveImage(_ sender: NSButton) {
    // 1. 创建保存面板
    let savePanel = NSSavePanel()

    // 2. 配置保存面板
    savePanel.allowedContentTypes = [.png]
    savePanel.nameFieldStringValue = "分享图_\(Date().timeIntervalSince1970).png"
    savePanel.title = "保存分享图片"
    savePanel.prompt = "保存"

    // 3. 显示保存面板
    savePanel.begin { [weak self] response in
        guard response == .OK, let url = savePanel.url else { return }

        // 4. 获取图片数据
        guard let image = self?.imageView.image,
              let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return
        }

        // 5. 保存文件
        do {
            try pngData.write(to: url)

            // 6. 显示成功提示
            let alert = NSAlert()
            alert.messageText = "保存成功"
            alert.informativeText = "图片已保存到: \(url.path)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "确定")
            alert.addButton(withTitle: "在 Finder 中显示")

            if alert.runModal() == .alertSecondButtonReturn {
                NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
            }
        } catch {
            // 7. 显示错误提示
            let alert = NSAlert()
            alert.messageText = "保存失败"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.runModal()
        }
    }
}
```

## 🔧 剪贴板更新

### 剪贴板同步实现

```swift
private func updateClipboard(with image: NSImage) {
    // 1. 获取剪贴板
    let pasteboard = NSPasteboard.general

    // 2. 清空剪贴板
    pasteboard.clearContents()

    // 3. 写入图片
    let success = pasteboard.writeObjects([image])

    // 4. 记录结果
    if success {
        print("图片已更新到剪贴板")
    } else {
        print("图片更新到剪贴板失败")
    }
}
```

## 🪟 窗口生命周期

### 窗口关闭处理

```swift
@objc private func windowWillClose(_ notification: Notification) {
    // 1. 移除通知观察者
    NotificationCenter.default.removeObserver(self)

    // 2. 清理资源
    imageView = nil
    themeSelector = nil
    saveButton = nil
    containerStackView = nil

    // 3. 打印日志
    print("预览窗口已关闭")
}
```

### 安全关闭机制

```swift
func safeClose() {
    // 1. 确保在主线程执行
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        // 2. 检查窗口是否可见
        if self.isVisible {
            // 3. 优雅关闭
            self.orderOut(nil)

            // 4. 可选：添加动画效果
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                self.animator().alphaValue = 0.0
            }) {
                self.close()
            }
        }
    }
}
```

## 🎯 用户交互优化

### 1. 键盘快捷键支持

```swift
override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case 1:  // S key
        if event.modifierFlags.contains(.command) {
            saveImage(saveButton)
        }
    case 53:  // Esc key
        safeClose()
    default:
        super.keyDown(with: event)
    }
}
```

### 2. 拖拽支持（扩展）

```swift
// 支持拖拽图片到其他应用
override func mouseDown(with event: NSEvent) {
    let dragLocation = event.locationInWindow

    // 检查是否点击在图片上
    if imageView.frame.contains(dragLocation) {
        let draggingItem = NSDraggingItem(pasteboardWriter: imageView.image!)
        draggingItem.setDraggingFrame(imageView.bounds, contents: imageView.image)

        beginDraggingSession(with: [draggingItem], event: event, source: self)
    } else {
        super.mouseDown(with: event)
    }
}
```

### 3. 双击关闭

```swift
override func mouseDown(with event: NSEvent) {
    if event.clickCount == 2 {
        safeClose()
    } else {
        super.mouseDown(with: event)
    }
}
```

## 🎨 UI 组件美化

### 1. 按钮样式定制

```swift
private func styleSaveButton() {
    saveButton.bezelStyle = .rounded
    saveButton.controlSize = .regular

    // 自定义按钮颜色
    if let cell = saveButton.cell as? NSButtonCell {
        cell.isBordered = true
        cell.backgroundColor = NSColor.controlAccentBlue
        cell.isOpaque = false
    }
}
```

### 2. 主题选择器美化

```swift
private func styleThemeSelector() {
    themeSelector.segmentStyle = .rounded
    themeSelector.controlSize = .regular

    // 设置分段颜色
    themeSelector.selectedSegmentBezelColor = NSColor.controlAccentBlue
    themeSelector.segmentStyle = .texturedRounded
}
```

### 3. 窗口阴影效果

```swift
private func setupWindowShadow() {
    guard let contentView = contentView else { return }

    contentView.wantsLayer = true
    contentView.layer?.shadowColor = NSColor.black.cgColor
    contentView.layer?.shadowOpacity = 0.2
    contentView.layer?.shadowOffset = NSSize(width: 0, height: -2)
    contentView.layer?.shadowRadius = 10
}
```

## 🐛 常见问题

### 1. 窗口无法关闭

**问题**: 窗口关闭方法无效

**解决**:
```swift
// 确保在主线程执行
DispatchQueue.main.async {
    self.orderOut(nil)
    self.close()
}

// 或者使用安全关闭
func safeClose() {
    DispatchQueue.main.async { [weak self] in
        self?.orderOut(nil)
    }
}
```

### 2. 约束冲突

**问题**: Auto Layout 约束冲突警告

**解决**:
```swift
// 设置优先级
constraint.priority = NSLayoutConstraint.Priority(rawValue: 999)

// 避免设置冲突的约束
imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
```

### 3. 内存泄漏

**问题**: 窗口重复创建导致内存增长

**解决**:
```swift
// 使用 weak 引用
NotificationCenter.default.addObserver(
    self,
    selector: #selector(windowWillClose(_:)),
    name: NSWindow.willCloseNotification,
    object: self  // 只监听自己的关闭事件
)

// 在关闭时清理
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

## 📚 相关文档

- [应用代理](04-app-delegate.md) - 了解窗口的创建和管理
- [图片生成](05-image-generator.md) - 掌握图片的处理逻辑

---

**下一步：建议阅读 [构建系统](07-build-system.md) 来了解项目的编译和部署流程。**