import Foundation

// MARK: - Configuration Error
// Modern Swift error handling for configuration validation

enum ConfigurationError: LocalizedError, Equatable {
    case invalidFontFamily(String)
    case invalidFontSize(String)
    case invalidTheme(String)
    case invalidPadding(Double)
    case invalidMaxWidth(Double)
    case invalidLineHeight(Double)
    case invalidCornerRadius(Double)
    case invalidBorderWidth(Double)
    case configurationCorrupted
    case fileNotFound
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .invalidFontFamily(let family):
            return "无效的字体族：\(family)"
        case .invalidFontSize(let size):
            return "无效的字体大小：\(size)"
        case .invalidTheme(let theme):
            return "无效的主题：\(theme)"
        case .invalidPadding(let padding):
            return "无效的边距：\(padding)"
        case .invalidMaxWidth(let maxWidth):
            return "无效的最大宽度：\(maxWidth)"
        case .invalidLineHeight(let lineHeight):
            return "无效的行高：\(lineHeight)"
        case .invalidCornerRadius(let cornerRadius):
            return "无效的圆角半径：\(cornerRadius)"
        case .invalidBorderWidth(let borderWidth):
            return "无效的边框宽度：\(borderWidth)"
        case .configurationCorrupted:
            return "配置文件已损坏"
        case .fileNotFound:
            return "找不到配置文件"
        case .permissionDenied:
            return "权限被拒绝"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidFontFamily, .invalidFontSize, .invalidTheme:
            return "请选择有效的配置值"
        case .invalidPadding, .invalidMaxWidth, .invalidLineHeight, .invalidCornerRadius, .invalidBorderWidth:
            return "请检查数值范围"
        case .configurationCorrupted:
            return "将重置为默认配置"
        case .fileNotFound:
            return "将创建新的配置文件"
        case .permissionDenied:
            return "请检查文件权限"
        }
    }
}