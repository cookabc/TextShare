# 图片生成引擎详解

## 🎨 ImageGenerator 核心实现

`ImageGenerator` 是 TextToShare 应用的核心引擎，负责将文本转换为美观的图片。它支持三种主题样式，自动处理文本布局，并优化了渲染性能。

## 📋 类结构概览

```swift
class ImageGenerator {
    // MARK: - Properties
    private let maxImageWidth: CGFloat = 600
    private let padding: CGFloat = 40
    private let cornerRadius: CGFloat = 8
    private let fontSize: CGFloat = 24
    private let lineHeight: CGFloat = 8

    // MARK: - Public Methods
    func generateImage(from text: String, theme: Theme) -> NSImage?

    // MARK: - Private Methods
    private func calculateImageSize(for text: String, attributes: [NSAttributedString.Key: Any]) -> NSSize
    private func drawBackground(in rect: NSRect, theme: ThemeConfig)
    private func drawText(in rect: NSRect, text: String, attributes: [NSAttributedString.Key: Any])
}
```

## 🎯 核心功能：generateImage

### 主函数解析

```swift
func generateImage(from text: String, theme: Theme) -> NSImage? {
    // 1. 获取主题配置
    let config = ThemeConfig.config(for: theme)

    // 2. 设置文本样式
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .medium),
        .foregroundColor: config.textColor,
        .paragraphStyle: {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight
            paragraphStyle.alignment = .left
            return paragraphStyle
        }()
    ]

    // 3. 计算文本尺寸
    let textSize = calculateImageSize(for: text, attributes: attributes)

    // 4. 计算最终图片尺寸
    let imageSize = NSSize(
        width: max(400, textSize.width + padding * 2),
        height: max(200, textSize.height + padding * 2)
    )

    // 5. 创建图片
    let image = NSImage(size: imageSize)
    image.lockFocus()

    let rect = NSRect(origin: .zero, size: imageSize)

    // 6. 绘制背景
    drawBackground(in: rect, theme: config)

    // 7. 绘制文本
    drawText(in: rect, text: text, attributes: attributes)

    // 8. 完成绘制
    image.unlockFocus()

    return image
}
```

## 📐 尺寸计算算法

### 文本尺寸计算

```swift
private func calculateImageSize(for text: String, attributes: [NSAttributedString.Key: Any]) -> NSSize {
    // 1. 创建属性字符串
    let attributedString = NSAttributedString(string: text, attributes: attributes)

    // 2. 计算边界矩形
    let boundingRect = attributedString.boundingRect(
        with: NSSize(width: maxImageWidth, height: CGFloat.greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )

    // 3. 返回文本尺寸
    return boundingRect.size
}
```

#### 技术细节

1. **最大宽度限制**
   ```swift
   width: maxImageWidth  // 600像素
   ```
   - 防止图片过宽
   - 保持良好的阅读体验
   - 适配社交媒体分享

2. **高度动态计算**
   ```swift
   height: CGFloat.greatestFiniteMagnitude
   ```
   - 根据文本内容自动调整
   - 支持长文本内容

3. **绘制选项**
   ```swift
   .usesLineFragmentOrigin    // 使用行片段原点
   .usesFontLeading          // 考虑字体行距
   ```
   - 确保文本布局正确
   - 保留原有的行间距

4. **最终尺寸调整**
   ```swift
   let imageSize = NSSize(
       width: max(400, textSize.width + padding * 2),   // 最小宽度400px
       height: max(200, textSize.height + padding * 2)  // 最小高度200px
   )
   ```

## 🎨 主题系统实现

### Theme 枚举定义

```swift
enum Theme {
    case light      // 浅色主题
    case dark       // 深色主题
    case gradient   // 渐变主题
}
```

### ThemeConfig 配置结构

```swift
struct ThemeConfig {
    let backgroundColor: NSColor
    let textColor: NSColor
    let borderColor: NSColor?
    let cornerRadius: CGFloat

    static func config(for theme: Theme) -> ThemeConfig {
        switch theme {
        case .light:
            return ThemeConfig(
                backgroundColor: NSColor.white,
                textColor: NSColor.black,
                borderColor: NSColor.lightGray,
                cornerRadius: 8
            )

        case .dark:
            return ThemeConfig(
                backgroundColor: NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0),
                textColor: NSColor.white,
                borderColor: NSColor.darkGray,
                cornerRadius: 8
            )

        case .gradient:
            return ThemeConfig(
                backgroundColor: NSColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0),
                textColor: NSColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0),
                borderColor: NSColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0),
                cornerRadius: 12
            )
        }
    }
}
```

#### 主题特点

1. **浅色主题**
   - 背景：纯白色
   - 文字：纯黑色
   - 边框：浅灰色
   - 圆角：8px

2. **深色主题**
   - 背景：深灰色 (RGB: 0.1, 0.1, 0.1)
   - 文字：白色
   - 边框：深灰色
   - 圆角：8px

3. **渐变主题**
   - 背景：浅蓝紫色 (RGB: 0.95, 0.95, 1.0)
   - 文字：深蓝紫色 (RGB: 0.1, 0.1, 0.3)
   - 边框：蓝紫色 (RGB: 0.7, 0.7, 1.0)
   - 圆角：12px（更圆润）

## 🖼️ 背景绘制实现

### drawBackground 方法详解

```swift
private func drawBackground(in rect: NSRect, theme: ThemeConfig) {
    // 1. 创建绘制路径
    let path = NSBezierPath(roundedRect: rect,
                           xRadius: theme.cornerRadius,
                           yRadius: theme.cornerRadius)

    // 2. 设置背景色并填充
    theme.backgroundColor.setFill()
    path.fill()

    // 3. 如果有边框，绘制边框
    if let borderColor = theme.borderColor {
        borderColor.setStroke()
        path.lineWidth = 1
        path.stroke()
    }
}
```

### 渐变背景实现（扩展功能）

```swift
// 如果要支持真正的渐变背景
private func drawGradientBackground(in rect: NSRect, config: ThemeConfig) {
    // 1. 创建渐变对象
    let gradient = NSGradient(colors: [
        config.backgroundColor,
        NSColor(red: config.backgroundColor.redComponent * 0.9,
               green: config.backgroundColor.greenComponent * 0.9,
               blue: config.backgroundColor.blueComponent * 0.9,
               alpha: 1.0)
    ])

    // 2. 创建圆角路径
    let path = NSBezierPath(roundedRect: rect,
                           xRadius: config.cornerRadius,
                           yRadius: config.cornerRadius)

    // 3. 绘制渐变
    gradient?.draw(in: path, angle: 45)

    // 4. 绘制边框
    if let borderColor = config.borderColor {
        borderColor.setStroke()
        path.lineWidth = 1
        path.stroke()
    }
}
```

## ✏️ 文本绘制实现

### drawText 方法详解

```swift
private func drawText(in rect: NSRect, text: String, attributes: [NSAttributedString.Key: Any]) {
    // 1. 计算文本绘制区域（考虑内边距）
    let textRect = NSRect(
        x: padding,
        y: padding,
        width: rect.width - padding * 2,
        height: rect.height - padding * 2
    )

    // 2. 创建属性字符串
    let attributedString = NSAttributedString(string: text, attributes: attributes)

    // 3. 绘制文本
    attributedString.draw(in: textRect)
}
```

#### 文本布局优化

1. **内边距处理**
   ```swift
   // 四周保留 40px 内边距
   let padding: CGFloat = 40
   ```

2. **文本对齐**
   ```swift
   paragraphStyle.alignment = .left  // 左对齐
   ```

3. **行间距设置**
   ```swift
   paragraphStyle.lineSpacing = lineHeight  // 8px
   ```

4. **字体选择**
   ```swift
   .font: NSFont.systemFont(ofSize: 24, weight: .medium)
   ```
   - 系统字体，兼容性好
   - 24px 大小，清晰易读
   - medium 字重，不过粗也不过细

## 🔧 性能优化

### 1. 内存管理

```swift
// 使用自动释放池
func generateImage(from text: String, theme: Theme) -> NSImage? {
    return autoreleasepool {
        // 图片生成代码
        // 自动管理临时对象
    }
}
```

### 2. 缓存优化（扩展）

```swift
// 可扩展的缓存系统
class ImageGenerator {
    private var cache: [String: NSImage] = [:]

    func generateImage(from text: String, theme: Theme) -> NSImage? {
        let cacheKey = "\(text.hashValue)_\(theme.hashValue)"

        if let cached = cache[cacheKey] {
            return cached
        }

        let image = createImage(from: text, theme: theme)
        cache[cacheKey] = image
        return image
    }
}
```

### 3. 异步生成（扩展）

```swift
// 支持异步图片生成
func generateImageAsync(from text: String, theme: Theme, completion: @escaping (NSImage?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let image = self.generateImage(from: text, theme: theme)
        DispatchQueue.main.async {
            completion(image)
        }
    }
}
```

## 🎨 高级功能扩展

### 1. 代码高亮支持

```swift
// 扩展：支持代码高亮
func generateCodeImage(from code: String, language: String, theme: Theme) -> NSImage? {
    // 使用语法高亮库
    let highlightedCode = highlight(code: code, language: language)
    return generateImage(from: highlightedCode, theme: theme)
}
```

### 2. 自定义字体

```swift
// 支持自定义字体
struct FontConfig {
    let name: String
    let size: CGFloat
    let weight: NSFont.Weight

    static let code = FontConfig(name: "Menlo", size: 20, weight: .regular)
    static let text = FontConfig(name: "SF Pro", size: 24, weight: .medium)
}
```

### 3. 水印功能

```swift
// 添加水印
private func drawWatermark(in rect: NSRect) {
    let watermarkText = "Generated by TextToShare"
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 12),
        .foregroundColor: NSColor.gray.withAlphaComponent(0.5)
    ]

    let attributedString = NSAttributedString(string: watermarkText, attributes: attributes)
    let textSize = attributedString.size()

    let watermarkRect = NSRect(
        x: rect.width - textSize.width - 10,
        y: 10,
        width: textSize.width,
        height: textSize.height
    )

    attributedString.draw(in: watermarkRect)
}
```

## 🐛 常见问题解决

### 1. 文本截断问题

**问题**: 长文本被截断

**解决**:
```swift
// 确保高度计算正确
let boundingRect = attributedString.boundingRect(
    with: NSSize(width: maxImageWidth, height: .greatestFiniteMagnitude),
    options: [.usesLineFragmentOrigin, .usesFontLeading],
    context: nil
).integral
```

### 2. 图片模糊问题

**问题**: 生成的图片模糊

**解决**:
```swift
// 设置正确的分辨率
image.size = imageSize
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(imageSize.width),
    pixelsHigh: Int(imageSize.height),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .calibratedRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)
image.addRepresentation(rep)
```

### 3. 内存泄漏问题

**问题**: 大量生成图片后内存增长

**解决**:
```swift
// 使用自动释放池
autoreleasepool {
    let image = NSImage(size: imageSize)
    image.lockFocus()
    // 绘制代码
    image.unlockFocus()
    return image
}
```

## 📚 相关文档

- [主题系统](08-themes-system.md) - 深入了解主题设计的细节
- [预览窗口](06-popup-window.md) - 学习图片的显示和交互

---

**下一步：建议阅读 [预览窗口](06-popup-window.md) 来了解图片展示的用户界面实现。**