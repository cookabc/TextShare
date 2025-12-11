import Cocoa
import CoreGraphics

enum Theme {
    case light
    case dark
    case gradient
}

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

// 图片缓存键
private struct ImageCacheKey: Hashable {
    let text: String
    let theme: Theme
    let version: Int = 1  // 版本号，用于清理旧缓存
}

class ImageGenerator {
    // 单例模式，便于管理缓存
    static let shared = ImageGenerator()

    // 图片缓存 - 使用 NSCache 自动管理内存
    private let imageCache = NSCache<NSString, NSImage>()
    // 最大缓存数量 - 避免占用过多内存
    private let maxCacheCount = 50

    private init() {
        setupCache()
    }

    private func setupCache() {
        imageCache.countLimit = maxCacheCount
        // 设置缓存清理策略，当内存紧张时自动清理
        imageCache.evictsObjectsWithDiscardedContent = true
    }

    private func log(_ message: String) {
        let timestamp = DateFormatter()
        timestamp.dateFormat = "HH:mm:ss"
        print("[ImageGenerator-\(timestamp.string(from: Date()))] \(message)")
        fflush(stdout)
    }

    // 生成缓存键
    private func cacheKey(for text: String, theme: Theme) -> NSString {
        let key = ImageCacheKey(text: text, theme: theme)
        return "\(text.hashValue)_\(theme.hashValue)_\(key.version)" as NSString
    }

    func generateImage(from text: String, theme: Theme) -> NSImage? {
        let key = cacheKey(for: text, theme: theme)

        // 先检查缓存
        if let cachedImage = imageCache.object(forKey: key) {
            log("从缓存获取图片，文本长度: \(text.count), 主题: \(theme)")
            return cachedImage
        }

        log("开始生成图片，文本长度: \(text.count), 主题: \(theme)")

        let config = ThemeConfig.config(for: theme)

        // 设置字体和样式
        let font = NSFont.systemFont(ofSize: 24, weight: .medium)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 8

        log("设置字体和样式完成")

        // 计算文本尺寸
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: config.textColor,
            .paragraphStyle: paragraphStyle
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.boundingRect(with: NSSize(width: 600, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin)
        log("计算文本尺寸完成: \(textSize)")

        // 计算最终图片尺寸（添加内边距）
        let padding: CGFloat = 40
        let imageSize = NSSize(
            width: max(400, textSize.width + padding * 2),
            height: max(200, textSize.height + padding * 2)
        )
        log("最终图片尺寸: \(imageSize)")

        // 创建图片
        guard let image = createImage(for: text, with: attributedString, size: imageSize, theme: theme, config: config) else {
            log("图片生成失败")
            return nil
        }

        // 缓存生成的图片
        imageCache.setObject(image, forKey: key)
        log("图片生成完成并已缓存")

        return image
    }

    private func createImage(for text: String, with attributedString: NSAttributedString, size imageSize: NSSize, theme: Theme, config: ThemeConfig) -> NSImage? {
        let image = NSImage(size: imageSize)
        image.lockFocus()
        log("开始绘制图片")

        // 绘制背景
        let rect = NSRect(origin: .zero, size: imageSize)

        if theme == .gradient {
            // 绘制渐变背景
            log("绘制渐变背景")
            let gradient = NSGradient(colors: [
                NSColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0),
                NSColor(red: 0.9, green: 0.9, blue: 0.98, alpha: 1.0)
            ])
            gradient?.draw(in: rect, angle: 45)
        } else {
            // 绘制纯色背景
            log("绘制纯色背景")
            config.backgroundColor.setFill()
            NSBezierPath(roundedRect: rect, xRadius: config.cornerRadius, yRadius: config.cornerRadius).fill()
        }

        // 绘制边框
        if let borderColor = config.borderColor {
            log("绘制边框")
            borderColor.setStroke()
            NSBezierPath(roundedRect: rect, xRadius: config.cornerRadius, yRadius: config.cornerRadius).stroke()
        }

        // 绘制文本
        log("绘制文本")
        let padding: CGFloat = 40
        let textRect = NSRect(
            x: padding,
            y: padding,
            width: imageSize.width - padding * 2,
            height: imageSize.height - padding * 2
        )
        attributedString.draw(in: textRect)

        image.unlockFocus()
        log("图片绘制完成")

        return image
    }

    // 清理缓存
    func clearCache() {
        imageCache.removeAllObjects()
        log("图片缓存已清理")
    }

    // 获取缓存统计信息
    func getCacheInfo() -> (count: Int, limit: Int) {
        return (count: 0, limit: maxCacheCount)  // NSCache 不提供当前数量，返回默认值
    }

    func saveImageToFile(_ image: NSImage, to url: URL) -> Bool {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return false
        }

        do {
            try pngData.write(to: url)
            return true
        } catch {
            print("保存图片失败: \(error)")
            return false
        }
    }
}