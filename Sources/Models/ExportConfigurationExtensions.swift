import Foundation

// MARK: - Export Configuration Extensions
// Adding Codable support for ExportConfiguration

extension ExportConfiguration: Codable {
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