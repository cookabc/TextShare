import Cocoa

// 字体配置管理
class FontConfig {
    static let shared = FontConfig()

    private init() {}

    // 支持的字体族
    enum FontFamily: String, CaseIterable {
        case system = "System"
        case avenir = "Avenir"
        case helvetica = "Helvetica Neue"
        case menlo = "Menlo"
        case monaco = "Monaco"

        var displayName: String {
            switch self {
            case .system: return "系统字体"
            case .avenir: return "Avenir"
            case .helvetica: return "Helvetica Neue"
            case .menlo: return "Menlo (代码)"
            case .monaco: return "Monaco (代码)"
            }
        }

        var isCodeFont: Bool {
            return self == .menlo || self == .monaco
        }
    }

    // 预设尺寸
    enum FontSize: CGFloat, CaseIterable {
        case small = 16
        case medium = 20
        case large = 24
        case extraLarge = 32

        var displayName: String {
            switch self {
            case .small: return "小号"
            case .medium: return "中号"
            case .large: return "大号"
            case .extraLarge: return "特大"
            }
        }
    }

    // 导出配置
    struct ExportConfig {
        let fontFamily: FontFamily
        let fontSize: FontSize
        let padding: CGFloat
        let maxWidth: CGFloat
        let lineHeight: CGFloat
        let watermark: String?

        static let `default` = ExportConfig(
            fontFamily: .system,
            fontSize: .medium,
            padding: 40,
            maxWidth: 600,
            lineHeight: 1.4,
            watermark: nil
        )
    }

    // 获取当前配置
    private var currentConfig: ExportConfig = .default

    func getCurrentConfig() -> ExportConfig {
        return currentConfig
    }

    func updateConfig(_ config: ExportConfig) {
        currentConfig = config
        saveConfig()
    }

    // 获取字体
    func getFont() -> NSFont {
        let family = currentConfig.fontFamily
        let size = currentConfig.fontSize

        if family == .system {
            return NSFont.systemFont(ofSize: size.rawValue, weight: .medium)
        } else {
            return NSFont(name: family.rawValue, size: size.rawValue) ??
                   NSFont.systemFont(ofSize: size.rawValue, weight: .medium)
        }
    }

    // 保存配置到 UserDefaults
    private func saveConfig() {
        let config = currentConfig
        UserDefaults.standard.set(config.fontFamily.rawValue, forKey: "fontFamily")
        UserDefaults.standard.set(config.fontSize.rawValue, forKey: "fontSize")
        UserDefaults.standard.set(config.padding, forKey: "padding")
        UserDefaults.standard.set(config.maxWidth, forKey: "maxWidth")
        UserDefaults.standard.set(config.lineHeight, forKey: "lineHeight")
        UserDefaults.standard.set(config.watermark, forKey: "watermark")
    }

    // 从 UserDefaults 加载配置
    func loadConfig() {
        let fontFamily = FontFamily(rawValue: UserDefaults.standard.string(forKey: "fontFamily") ?? "System") ?? .system
        let fontSizeValue = UserDefaults.standard.object(forKey: "fontSize") as? CGFloat ?? FontSize.medium.rawValue
        let fontSize = FontSize.allCases.first { $0.rawValue == fontSizeValue } ?? .medium
        let padding = UserDefaults.standard.object(forKey: "padding") as? CGFloat ?? 40
        let maxWidth = UserDefaults.standard.object(forKey: "maxWidth") as? CGFloat ?? 600
        let lineHeight = UserDefaults.standard.object(forKey: "lineHeight") as? CGFloat ?? 1.4
        let watermark = UserDefaults.standard.string(forKey: "watermark")

        currentConfig = ExportConfig(
            fontFamily: fontFamily,
            fontSize: fontSize,
            padding: padding,
            maxWidth: maxWidth,
            lineHeight: lineHeight,
            watermark: watermark
        )
    }
}

// 错误处理增强
enum ImageGenerationError: LocalizedError {
    case textTooLong(maxLength: Int)
    case unsupportedCharacter(characters: [Character])
    case renderFailure(reason: String)
    case clipboardEmpty
    case fontNotFound

    var errorDescription: String? {
        switch self {
        case .textTooLong(let maxLength):
            return "文本过长，请限制在 \(maxLength) 个字符以内"
        case .unsupportedCharacter(let characters):
            let chars = characters.map { String($0) }.joined()
            return "包含不支持的特殊字符：\(chars)"
        case .renderFailure(let reason):
            return "图片生成失败：\(reason)"
        case .clipboardEmpty:
            return "剪贴板为空，请先复制一些文本"
        case .fontNotFound:
            return "找不到指定的字体，已使用系统字体替代"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .textTooLong:
            return "请缩短文本长度或分段生成多张图片"
        case .unsupportedCharacter:
            return "请移除特殊字符或尝试使用系统字体"
        case .renderFailure:
            return "请重启应用或更换字体试试"
        case .clipboardEmpty:
            return "复制一些文本后再次尝试"
        case .fontNotFound:
            return "已自动使用系统字体生成图片"
        }
    }
}