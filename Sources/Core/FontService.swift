import Foundation
import AppKit
import CoreGraphics

// MARK: - Modern Font Service
// Modern Swift features: async/await, actor pattern, error handling

actor FontService {
    static let shared = FontService()

    private let cache = NSCache<NSString, NSFont>()
    private let maxCacheSize = 50

    private init() {
        cache.countLimit = maxCacheSize
        cache.evictsObjectsWithDiscardedContent = true
    }

    // MARK: - Font Generation
    func generateFont(
        family: ModernFontFamily,
        size: ModernFontSize,
        weight: NSFont.Weight = .medium
    ) async -> NSFont {
        let cacheKey = "\(family.rawValue)_\(size.rawValue)_\(weight.rawValue)" as NSString

        if let cachedFont = cache.object(forKey: cacheKey) {
            return cachedFont
        }

        let font: NSFont
        if family == .system {
            font = NSFont.systemFont(ofSize: size.pointSize, weight: weight)
        } else {
            font = NSFont(name: family.rawValue, size: size.pointSize)
                   ?? NSFont.systemFont(ofSize: size.pointSize, weight: weight)
        }

        cache.setObject(font, forKey: cacheKey)
        return font
    }

    // MARK: - Font Metrics Calculation
    func calculateTextSize(
        for text: String,
        using font: NSFont,
        maxWidth: CGFloat,
        lineHeight: CGFloat
    ) async -> CGSize {
        return await Task.detached { () -> CGSize in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = (lineHeight * font.pointSize) - font.pointSize
                    style.alignment = .left
                    return style
                }()
            ]

            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let boundingRect = attributedString.boundingRect(
                with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading]
            )

            return CGSize(
                width: min(boundingRect.width, maxWidth),
                height: boundingRect.height
            )
        }.value
    }

    // MARK: - Font Rendering
    func renderText(
        text: String,
        in rect: NSRect,
        with configuration: ExportConfiguration
    ) async throws -> NSImage {
        let font = await generateFont(
            family: configuration.fontFamily,
            size: configuration.fontSize
        )

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: configuration.theme.textColor,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = (configuration.lineHeight * font.pointSize) - font.pointSize
                style.alignment = .left
                return style
            }(),
            .kern: configuration.fontSize.letterSpacing
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let image = NSImage(size: rect.size)

        image.lockFocus()
        defer { image.unlockFocus() }

        // Create a graphics context
        guard let context = NSGraphicsContext.current else {
            throw FontServiceError.renderingFailed
        }

        // Clear background if needed
        if configuration.theme == .minimalist {
            NSColor.white.setFill()
            rect.fill()
        }

        // Draw text
        let textRect = rect.insetBy(dx: configuration.padding, dy: configuration.padding)
        attributedString.draw(in: textRect)

        return image
    }

    // MARK: - Font Validation
    func validateConfiguration(_ config: ExportConfiguration) async -> [FontValidationError] {
        var errors: [FontValidationError] = []

        // Test if font can be created
        do {
            let testFont = await generateFont(family: config.fontFamily, size: config.fontSize)
            if testFont.fontName.isEmpty {
                errors.append(.fontNotFound(config.fontFamily.displayName))
            }
        } catch {
            errors.append(.fontCreationFailed(config.fontFamily.displayName))
        }

        // Test text rendering with sample text
        do {
            let sampleText = "Sample text for validation"
            let sampleSize = await calculateTextSize(
                for: sampleText,
                using: await generateFont(family: config.fontFamily, size: config.fontSize),
                maxWidth: config.maxWidth,
                lineHeight: config.lineHeight
            )

            if sampleSize.width > config.maxWidth {
                errors.append(.textTooWide(Int(sampleSize.width), Int(config.maxWidth)))
            }

            if sampleSize.height > 1000 { // Reasonable max height
                errors.append(.textTooTall(Int(sampleSize.height)))
            }
        } catch {
            errors.append(.renderingTestFailed)
        }

        return errors
    }

    // MARK: - Cache Management
    func clearCache() async {
        cache.removeAllObjects()
    }

    func getCacheInfo() async -> (count: Int, limit: Int) {
        return (0, maxCacheSize) // NSCache doesn't expose count
    }
}

// MARK: - Font Service Errors
enum FontServiceError: LocalizedError {
    case renderingFailed
    case fontNotFound(String)
    case fontCreationFailed(String)

    var errorDescription: String? {
        switch self {
        case .renderingFailed:
            return "Failed to create graphics context"
        case .fontNotFound(let fontName):
            return "Font '\(fontName)' not found"
        case .fontCreationFailed(let fontName):
            return "Failed to create font '\(fontName)'"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .renderingFailed:
            return "Try restarting the application"
        case .fontNotFound:
            return "Choose a different font family"
        case .fontCreationFailed:
            return "Use the system font instead"
        }
    }
}

enum FontValidationError: LocalizedError {
    case fontNotFound(String)
    case fontCreationFailed(String)
    case textTooWide(Int, Int)
    case textTooTall(Int)
    case renderingTestFailed

    var errorDescription: String? {
        switch self {
        case .fontNotFound(let fontName):
            return "Font '\(fontName)' is not available"
        case .fontCreationFailed(let fontName):
            return "Cannot create font '\(fontName)'"
        case .textTooWide(let width, let maxWidth):
            return "Text is too wide (\(width)px) for max width (\(maxWidth)px)"
        case .textTooTall(let height):
            return "Text is too tall (\(height)px)"
        case .renderingTestFailed:
            return "Failed to test text rendering"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fontNotFound, .fontCreationFailed:
            return "Try using the system font"
        case .textTooWide:
            return "Increase the maximum width or shorten the text"
        case .textTooTall:
            return "Break the text into smaller chunks"
        case .renderingTestFailed:
            return "Check the font configuration"
        }
    }
}

// MARK: - Font Metrics Calculator
actor FontMetricsCalculator {
    static let shared = FontMetricsCalculator()

    func calculateOptimalImageSize(
        for text: String,
        with config: ExportConfiguration,
        font: NSFont
    ) async -> CGSize {
        let textSize = await FontService.shared.calculateTextSize(
            for: text,
            using: font,
            maxWidth: config.maxWidth,
            lineHeight: config.lineHeight
        )

        return CGSize(
            width: max(400, textSize.width + config.padding * 2),
            height: max(200, textSize.height + config.padding * 2)
        )
    }

    func calculateTextBounds(
        for text: String,
        with config: ExportConfiguration
    ) async -> CGRect {
        let font = await FontService.shared.generateFont(
            family: config.fontFamily,
            size: config.fontSize
        )

        let textSize = await FontService.shared.calculateTextSize(
            for: text,
            using: font,
            maxWidth: config.maxWidth,
            lineHeight: config.lineHeight
        )

        return CGRect(
            x: config.padding,
            y: config.padding,
            width: textSize.width,
            height: textSize.height
        )
    }
}

// MARK: - Font Preview Generator
actor FontPreviewGenerator {
    static let shared = FontPreviewGenerator()

    func generatePreview(
        for text: String,
        with config: ExportConfiguration
    ) async throws -> NSImage {
        let font = await FontService.shared.generateFont(
            family: config.fontFamily,
            size: config.fontSize
        )

        let previewSize = await FontMetricsCalculator.shared.calculateOptimalImageSize(
            for: text,
            with: config,
            font: font
        )

        let previewRect = NSRect(origin: .zero, size: previewSize)

        return try await FontService.shared.renderText(
            text: text,
            in: previewRect,
            with: config
        )
    }

    func generateThemePreviews(
        for text: String,
        baseConfig: ExportConfiguration
    ) async -> [ModernTheme: NSImage] {
        var previews: [ModernTheme: NSImage] = [:]

        for theme in ModernTheme.allCases {
            var config = baseConfig
            config.theme = theme

            do {
                let preview = try await generatePreview(for: text, with: config)
                previews[theme] = preview
            } catch {
                print("Failed to generate preview for theme \(theme.displayName): \(error)")
            }
        }

        return previews
    }
}