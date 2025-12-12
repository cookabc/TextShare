# 开发指南

## 🛠️ 开发环境搭建

### 系统要求

- **操作系统**: macOS 13.0 或更高版本
- **Xcode**: 14.0 或更高版本（用于命令行工具）
- **Swift**: 5.7 或更高版本
- **内存**: 至少 4GB RAM
- **磁盘**: 1GB 可用空间

### 安装步骤

#### 1. 安装 Xcode Command Line Tools

```bash
# 方法 1: 通过命令行安装
xcode-select --install

# 方法 2: 从 App Store 安装 Xcode
# 然后运行以下命令
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

#### 2. 验证安装

```bash
# 检查 Swift 版本
swift --version

# 检查编译器
swiftc --version

# 检查开发工具路径
xcode-select -p
```

#### 3. 克隆项目

```bash
git clone <repository-url>
cd TextToShare
```

### IDE 配置

#### VS Code 配置

推荐扩展：
- Swift
- CodeLLDB
- C/C++
- GitLens

Workspace 设置 (`.vscode/settings.json`):
```json
{
    "swift.path": "/usr/bin/swift",
    "swift.buildPath": "${workspaceFolder}/build",
    "files.associations": {
        "*.swift": "swift"
    },
    "editor.formatOnSave": true,
    "swift.diagnostics": true
}
```

#### 调试配置 (`.vscode/launch.json`):
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "lldb",
            "request": "launch",
            "name": "Debug TextToShare",
            "program": "${workspaceFolder}/build/TextToShare",
            "args": [],
            "cwd": "${workspaceFolder}",
            "preLaunchTask": "build"
        }
    ]
}
```

## 🚀 快速开始

### 构建和运行

```bash
# 1. 给构建脚本执行权限
chmod +x build.sh

# 2. 构建项目
./build.sh

# 3. 运行应用
./build/TextToShare
```

### 验证功能

1. 复制一些文本到剪贴板
2. 按 `⌘⇧C` 快捷键
3. 查看预览窗口
4. 尝试切换主题
5. 测试保存功能

## 📝 代码规范

### 命名规范

```swift
// 类名：PascalCase
class ImageGenerator { }

// 结构体：PascalCase
struct ThemeConfig { }

// 枚举：PascalCase
enum Theme { }

// 属性和方法：camelCase
private var imageGenerator: ImageGenerator!
func generateImage(from text: String) -> NSImage? { }

// 常量：camelCase 或 UPPER_CASE
let maxImageWidth: CGFloat = 600
static let DEFAULT_FONT_SIZE: CGFloat = 24
```

### 文件组织

```swift
// MARK: - Properties
private var property: Type

// MARK: - Initialization
init() { }

// MARK: - Public Methods
public func publicMethod() { }

// MARK: - Private Methods
private func privateMethod() { }

// MARK: - Actions
@objc private func buttonTapped(_ sender: NSButton) { }

// MARK: - Utilities
private func utility() { }
```

### 注释规范

```swift
/// 图片生成器类
///
/// 负责将文本转换为不同主题的图片
/// 支持浅色、深色和渐变三种主题
class ImageGenerator {

    /// 生成图片
    ///
    /// - Parameters:
    ///   - text: 要转换的文本
    ///   - theme: 使用的主题
    /// - Returns: 生成的图片，失败返回 nil
    func generateImage(from text: String, theme: Theme) -> NSImage? {
        // 实现代码...
    }
}
```

## 🐛 调试技巧

### 日志系统

```swift
// 使用统一的日志格式
func log(_ message: String, level: LogLevel = .info) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timestamp = formatter.string(from: Date())

    let prefix: String
    switch level {
    case .debug:
        prefix = "🔍"
    case .info:
        prefix = "ℹ️"
    case .warning:
        prefix = "⚠️"
    case .error:
        prefix = "❌"
    }

    print("[\(timestamp)] \(prefix) [TextToShare] \(message)")
}

// 使用示例
log("应用启动完成", level: .info)
log("生成图片失败", level: .error)
```

### 断点调试

```swift
// 条件断点
if image.size.width > 1000 {
    print("图片过大")
    // 在此处设置断点
}

// 使用 assert 进行调试检查
assert(text.count > 0, "文本不能为空")
assert(image != nil, "图片生成成功")
```

### 内存调试

```swift
// 检测循环引用
deinit {
    print("对象被销毁")
}

// 使用 Instruments
// 1. 在 Xcode 中打开 Instruments
// 2. 选择 Leaks 或 Allocations
// 3. 选择应用进行测试
```

## 🔧 扩展开发

### 添加新主题

#### 1. 定义主题

```swift
enum Theme: Int, CaseIterable {
    case light = 0
    case dark = 1
    case gradient = 2
    case custom = 3  // 新增主题
}

extension ThemeConfig {
    static let customThemeConfig: ThemeConfig = ThemeConfig(
        backgroundColor: NSColor.systemYellow,
        textColor: NSColor.systemBrown,
        borderColor: NSColor.systemOrange,
        cornerRadius: 16,
        borderWidth: 2,
        shadowOpacity: 0.2
    )
}
```

#### 2. 实现绘制逻辑

```swift
private func drawCustomBackground(in rect: NSRect) {
    // 自定义背景绘制
    let path = NSBezierPath(roundedRect: rect, xRadius: 16, yRadius: 16)

    // 创建图案
    let pattern = NSImage(named: "pattern")!
    let patternColor = NSColor(patternImage: pattern)
    patternColor.setFill()
    path.fill()
}
```

### 添加快捷键

```swift
private func setupAdditionalHotKeys() {
    // Cmd+Shift+S: 保存默认主题
    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
        if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 1 {
            self?.saveWithDefaultTheme()
            return nil
        }
        return event
    }
}
```

### 批量处理功能

```swift
class BatchProcessor {
    func processMultipleTexts(_ texts: [String], theme: Theme) -> [NSImage] {
        return texts.compactMap { text in
            return ImageGenerator().generateImage(from: text, theme: theme)
        }
    }

    func exportToFolder(_ images: [NSImage], url: URL) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        for (index, image) in images.enumerated() {
            let fileName = "image_\(index + 1).png"
            let fileURL = url.appendingPathComponent(fileName)

            guard let tiffData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
                continue
            }

            try pngData.write(to: fileURL)
        }
    }
}
```

## 📦 构建和分发

### 开发构建

```bash
#!/bin/bash
# dev-build.sh - 开发模式构建

echo "🔨 开发模式构建..."

# 创建开发构建目录
mkdir -p build/dev

# 编译调试版本
swiftc -g -O0 \
       -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
       -o build/dev/TextToShare \
       -framework Cocoa \
       *.swift

echo "✅ 开发构建完成"
echo "运行: ./build/dev/TextToShare"
```

### 发布构建

```bash
#!/bin/bash
# release-build.sh - 发布模式构建

echo "🚀 发布模式构建..."

# 清理旧构建
rm -rf build/release

# 创建发布构建目录
mkdir -p build/release

# 优化的编译
swiftc -O \
       -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
       -o build/release/TextToShare \
       -framework Cocoa \
       *.swift

# 压缩可执行文件
lipo -thin $(uname -m) build/release/TextToShare \
     -output build/release/TextToShare.thin

echo "✅ 发布构建完成"
echo "文件大小: $(du -h build/release/TextToShare.thin)"
```

### 创建应用包

```bash
#!/bin/bash
# create-app.sh - 创建 .app 包

APP_NAME="TextToShare"
VERSION="1.0"
APP_PATH="build/$APP_NAME.app"
BIN_PATH="$APP_PATH/Contents/MacOS"
RES_PATH="$APP_PATH/Contents/Resources"

# 创建应用包结构
mkdir -p "$BIN_PATH"
mkdir -p "$RES_PATH"

# 复制可执行文件
cp build/release/TextToShare.thin "$BIN_PATH/$APP_NAME"
chmod +x "$BIN_PATH/$APP_NAME"

# 创建 Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.TextToShare</string>
    <key>CFBundleName</key>
    <string>文字分享图</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF

# 创建 PkgInfo
echo "APPL????" > "$APP_PATH/Contents/PkgInfo"

echo "✅ 应用包创建完成: $APP_PATH"
```

### 公证和分发

```bash
#!/bin/bash
# notarize.sh - 公证和分发

APP_PATH="build/TextToShare.app"
IDENTITY="Developer ID Application: Your Name"
BUNDLE_ID="com.example.TextToShare"

# 1. 签名应用
codesign --force --verify --verbose \
        --sign "$IDENTITY" \
        --options runtime \
        --entitlements entitlements.plist \
        "$APP_PATH"

# 2. 验证签名
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl --assess --type execute --verbose "$APP_PATH"

# 3. 创建 DMG
hdiutil create -volname "TextToShare" \
              -srcfolder "$APP_PATH" \
              -ov -format UDZO \
              "build/TextToShare.dmg"

# 4. 公证 DMG
xcrun altool --notarize-app \
           --primary-bundle-id "$BUNDLE_ID" \
           --username "your@email.com" \
           --password "@keychain:AC_PASSWORD" \
           --file "build/TextToShare.dmg"

# 5. 装订公证
xcrun stapler staple "build/TextToShare.dmg"

echo "✅ 公证完成"
```

## 📚 学习资源

### 官方文档

- [Swift Programming Language](https://docs.swift.org/swift-book/)
- [AppKit Framework](https://developer.apple.com/documentation/appkit)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

### 推荐书籍

1. **Swift Programming: The Big Nerd Ranch Guide**
   - 适合 Swift 入门
   - 实践导向

2. **macOS Programming for Absolute Beginners**
   - macOS 开发入门
   - 项目驱动学习

3. **Advanced Swift**
   - Swift 高级特性
   - 深入理解语言

### 在线课程

1. **Stanford CS193p**
   - iOS/macOS 开发课程
   - 免费视频资源

2. **Hacking with macOS**
   - 实战项目教程
   - 更新及时

### 社区资源

- [Swift Forums](https://forums.swift.org/) - Swift 官方论坛
- [Stack Overflow](https://stackoverflow.com/questions/tagged/swift+macos) - 问答社区
- [Reddit r/swift](https://www.reddit.com/r/swift/) - Swift 讨论社区

## 🚀 性能优化

### 代码优化

```swift
// 使用 defer 确保资源释放
func processImage(_ image: NSImage) -> NSImage? {
    let context = NSGraphicsContext.current
    defer {
        // 清理代码
    }

    // 处理逻辑
    return processedImage
}

// 使用 lazy 延迟初始化
lazy var imageGenerator: ImageGenerator = {
    let generator = ImageGenerator()
    generator.configure()
    return generator
}()
```

### 内存优化

```swift
// 使用对象池
class ImagePool {
    private var pool: [NSImage] = []
    private let maxPoolSize = 10

    func getImage() -> NSImage? {
        return pool.popLast() ?? NSImage()
    }

    func returnImage(_ image: NSImage) {
        if pool.count < maxPoolSize {
            pool.append(image)
        }
    }
}

// 使用自动释放池
autoreleasepool {
    let images = processLargeBatch()
    // 自动释放临时对象
}
```

### 启动优化

```swift
// 延迟加载非关键组件
class AppDelegate {
    private var _imageGenerator: ImageGenerator?

    var imageGenerator: ImageGenerator {
        if _imageGenerator == nil {
            _imageGenerator = ImageGenerator()
        }
        return _imageGenerator!
    }
}
```

## 🔍 故障排除

### 常见问题

1. **编译错误：找不到 Cocoa**
   ```bash
   # 解决方案
   xcode-select --install
   sudo xcode-select -r
   ```

2. **快捷键不响应**
   ```swift
   // 检查应用是否在前台
   NSApp.activate(ignoringOtherApps: true)
   ```

3. **剪贴板访问失败**
   ```swift
   // 添加延迟
   DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
       // 访问剪贴板
   }
   ```

### 调试工具

```bash
# 使用 lldb 调试
lldb ./build/TextToShare
(lldb) run

# 使用 dtrace 监控系统调用
sudo dtrace -n 'syscall::write*:entry /execname == "TextToShare"/ { printf("%s\n", probefunc); }'
```

## 📝 版本控制最佳实践

### .gitignore 配置

```gitignore
# 构建产物
build/
*.o
*.swiftdoc
*.swiftmodule

# IDE 配置
.vscode/
*.xcworkspace/
xcuserdata/

# 系统文件
.DS_Store
Thumbs.db
```

### 提交规范

```
feat: 添加新功能
fix: 修复 bug
docs: 更新文档
style: 代码格式调整
refactor: 代码重构
test: 添加测试
chore: 构建过程或辅助工具的变动
```

## 🎯 下一步

完成基础开发后，可以考虑以下扩展：

1. **添加更多主题** - 支持用户自定义主题
2. **批量处理** - 支持多文本同时处理
3. **云同步** - 同步设置到云端
4. **插件系统** - 支持第三方插件
5. **自动化** - 支持 AppleScript 或 Shortcuts

---

**恭喜！您已完成 TextToShare 项目的完整学习。现在可以开始开发自己的 macOS 应用了！** 🎉