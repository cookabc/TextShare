import Foundation

// MARK: - Export Configuration Base Structure
// Modern Swift configuration with type safety and validation

struct ExportConfiguration: Equatable, Codable {
    var fontFamily: ModernFontFamily = .system
    var fontSize: ModernFontSize = .medium
    var theme: ModernTheme = .light
    var padding: Double = 32
    var maxWidth: Double = 800
    var lineHeight: Double = 1.4
    var watermark: String?
    var cornerRadius: Double = 12
    var borderWidth: Double = 0
}

extension ExportConfiguration {
    static let `default` = ExportConfiguration()

    func with(fontFamily: ModernFontFamily) -> ExportConfiguration {
        var config = self
        config.fontFamily = fontFamily
        return config
    }

    func with(fontSize: ModernFontSize) -> ExportConfiguration {
        var config = self
        config.fontSize = fontSize
        return config
    }

    func with(theme: ModernTheme) -> ExportConfiguration {
        var config = self
        config.theme = theme
        return config
    }

    func with(padding: Double) -> ExportConfiguration {
        var config = self
        config.padding = padding
        return config
    }

    func with(maxWidth: Double) -> ExportConfiguration {
        var config = self
        config.maxWidth = maxWidth
        return config
    }

    func with(watermark: String?) -> ExportConfiguration {
        var config = self
        config.watermark = watermark
        return config
    }
}

// MARK: - Codable Support Implementation
extension ExportConfiguration {
    enum CodingKeys: String, CodingKey {
        case fontFamily, fontSize, theme, padding, maxWidth, lineHeight, watermark, cornerRadius, borderWidth
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fontFamily.rawValue, forKey: .fontFamily)
        try container.encode(fontSize.rawValue, forKey: .fontSize)
        try container.encode(theme.rawValue, forKey: .theme)
        try container.encode(padding, forKey: .padding)
        try container.encode(maxWidth, forKey: .maxWidth)
        try container.encode(lineHeight, forKey: .lineHeight)
        try container.encode(watermark, forKey: .watermark)
        try container.encode(cornerRadius, forKey: .cornerRadius)
        try container.encode(borderWidth, forKey: .borderWidth)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fontFamilyRaw = try container.decode(String.self, forKey: .fontFamily)
        let fontSizeRaw = try container.decode(String.self, forKey: .fontSize)
        let themeRaw = try container.decode(String.self, forKey: .theme)

        self.fontFamily = ModernFontFamily(rawValue: fontFamilyRaw) ?? .system
        self.fontSize = ModernFontSize(rawValue: fontSizeRaw) ?? .medium
        self.theme = ModernTheme(rawValue: themeRaw) ?? .light
        self.padding = try container.decode(Double.self, forKey: .padding)
        self.maxWidth = try container.decode(Double.self, forKey: .maxWidth)
        self.lineHeight = try container.decode(Double.self, forKey: .lineHeight)
        self.watermark = try container.decodeIfPresent(String.self, forKey: .watermark)
        self.cornerRadius = try container.decode(Double.self, forKey: .cornerRadius)
        self.borderWidth = try container.decode(Double.self, forKey: .borderWidth)
    }
}