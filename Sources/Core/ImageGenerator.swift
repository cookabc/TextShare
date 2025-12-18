import Foundation
import AppKit
import CoreGraphics
import SwiftUI

// MARK: - Modern Image Generator
// Modern Swift features: async/await, actor pattern, result types

actor ImageGenerator {
    static let shared = ImageGenerator()

    private init() {}

    // MARK: - Main Image Generation
    func generateImage(
        from text: String,
        with configuration: ExportConfiguration
    ) async throws -> Data {
        // Validate input
        guard !text.isEmpty else {
            throw ImageGenerationError.emptyText
        }

        // Generate font
        let font = await FontService.shared.generateFont(
            family: configuration.fontFamily,
            size: configuration.fontSize
        )

        // Calculate optimal size
        let optimalSize = await FontMetricsCalculator.shared.calculateOptimalImageSize(
            for: text,
            with: configuration,
            font: font
        )

        // Create image
        let image = try await generateImageInternal(
            text: text,
            font: font,
            configuration: configuration,
            size: optimalSize
        )

        // Convert to data
        return try convertToPNGData(image)
    }

    // MARK: - Internal Image Generation
    private func generateImageInternal(
        text: String,
        font: NSFont,
        configuration: ExportConfiguration,
        size: CGSize
    ) async throws -> NSImage {
        let image = NSImage(size: size)
        let rect = NSRect(origin: .zero, size: size)

        image.lockFocus()
        defer { image.unlockFocus() }

        // Create graphics context
        guard let context = NSGraphicsContext.current?.cgContext else {
            throw ImageGenerationError.contextCreationFailed
        }

        // Set up the context
        setupGraphicsContext(context, configuration: configuration)

        // Draw background
        try drawBackground(rect: rect, configuration: configuration)

        // Draw border if needed
        if configuration.borderWidth > 0 {
            drawBorder(rect: rect, configuration: configuration)
        }

        // Calculate text bounds
        let textBounds = await calculateTextBounds(
            text: text,
            font: font,
            configuration: configuration,
            containerSize: size
        )

        // Draw text
        try drawText(
            text: text,
            in: textBounds,
            font: font,
            configuration: configuration
        )

        // Draw watermark if provided
        if let watermark = configuration.watermark {
            try drawWatermark(
                watermark,
                in: rect,
                configuration: configuration
            )
        }

        return image
    }

    // MARK: - Graphics Context Setup
    private func setupGraphicsContext(_ context: CGContext, configuration: ExportConfiguration) {
        // Set rendering quality
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        context.setRenderingIntent(.defaultIntent)

        // Set interpolation quality
        context.interpolationQuality = .high

        // Apply color space
        if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            context.setFillColorSpace(colorSpace)
        }
    }

    // MARK: - Background Drawing
    private func drawBackground(rect: NSRect, configuration: ExportConfiguration) throws {
        guard let context = NSGraphicsContext.current?.cgContext else {
            throw ImageGenerationError.contextCreationFailed
        }

        let path = CGMutablePath()

        // Calculate corner radius
        let cornerRadius = min(configuration.cornerRadius, min(rect.width, rect.height) / 2)

        // Create rounded rectangle path
        path.addRoundedRect(in: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height), cornerWidth: cornerRadius, cornerHeight: cornerRadius)

        // Fill background
        context.setFillColor(configuration.theme.primaryColor.cgColor ?? CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.addPath(path)
        context.fillPath()
    }

    // MARK: - Border Drawing
    private func drawBorder(rect: NSRect, configuration: ExportConfiguration) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let cornerRadius = min(configuration.cornerRadius, min(rect.width, rect.height) / 2)
        let borderRect = rect.insetBy(dx: configuration.borderWidth / 2, dy: configuration.borderWidth / 2)

        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: borderRect.origin.x, y: borderRect.origin.y, width: borderRect.size.width, height: borderRect.size.height), cornerWidth: cornerRadius, cornerHeight: cornerRadius)

        context.setStrokeColor(configuration.theme.accentColor.cgColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.setLineWidth(configuration.borderWidth)
        context.addPath(path)
        context.strokePath()
    }

    // MARK: - Text Bounds Calculation
    private func calculateTextBounds(
        text: String,
        font: NSFont,
        configuration: ExportConfiguration,
        containerSize: CGSize
    ) async -> CGRect {
        let effectiveWidth = containerSize.width - (configuration.padding * 2)
        let effectiveHeight = containerSize.height - (configuration.padding * 2)

        let textSize = await FontService.shared.calculateTextSize(
            for: text,
            using: font,
            maxWidth: effectiveWidth,
            lineHeight: configuration.lineHeight
        )

        // Center the text
        let x = configuration.padding
        let y = (containerSize.height - textSize.height) / 2

        return CGRect(
            x: x,
            y: y,
            width: textSize.width,
            height: textSize.height
        )
    }

    // MARK: - Text Drawing
    private func drawText(
        text: String,
        in rect: CGRect,
        font: NSFont,
        configuration: ExportConfiguration
    ) throws {
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = (configuration.lineHeight * font.pointSize) - font.pointSize
        paragraphStyle.lineBreakMode = .byWordWrapping

        // Create text attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: configuration.theme.textColor,
            .paragraphStyle: paragraphStyle,
            .kern: configuration.fontSize.letterSpacing
        ]

        // Create attributed string
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        // Draw text
        attributedString.draw(in: rect)
    }

    // MARK: - Watermark Drawing
    private func drawWatermark(
        _ watermark: String,
        in rect: NSRect,
        configuration: ExportConfiguration
    ) throws {
        let watermarkAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .light),
            .foregroundColor: NSColor(configuration.theme.textColor).withAlphaComponent(0.3),
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .right
                return style
            }()
        ]

        let watermarkString = NSAttributedString(string: watermark, attributes: watermarkAttributes)
        let watermarkRect = CGRect(
            x: rect.width - 100,
            y: rect.height - 20,
            width: 90,
            height: 15
        )

        watermarkString.draw(in: watermarkRect)
    }

    // MARK: - Data Conversion
    private func convertToPNGData(_ image: NSImage) throws -> Data {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            throw ImageGenerationError.dataConversionFailed
        }

        guard let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            throw ImageGenerationError.dataConversionFailed
        }

        return pngData
    }

    // MARK: - Batch Generation (for previews)
    func generateThemePreviews(
        for text: String,
        baseConfiguration: ExportConfiguration
    ) async -> [ModernTheme: Data] {
        var previews: [ModernTheme: Data] = [:]

        for theme in ModernTheme.allCases {
            var config = baseConfiguration
            config.theme = theme

            do {
                let imageData = try await generateImage(from: text, with: config)
                previews[theme] = imageData
            } catch {
                print("Failed to generate preview for theme \(theme.displayName): \(error)")
            }
        }

        return previews
    }

    // MARK: - Validation
    func validateGenerationRequest(
        text: String,
        configuration: ExportConfiguration
    ) async -> [ImageGenerationError] {
        var errors: [ImageGenerationError] = []

        // Validate text
        if text.isEmpty {
            errors.append(.emptyText)
        } else if text.count > 10000 {
            errors.append(.textTooLong)
        }

        // Validate configuration
        if configuration.padding < 0 || configuration.padding > 100 {
            errors.append(.invalidPadding)
        }

        if configuration.maxWidth < 100 || configuration.maxWidth > 4000 {
            errors.append(.invalidMaxWidth)
        }

        if configuration.lineHeight < 0.5 || configuration.lineHeight > 5.0 {
            errors.append(.invalidLineHeight)
        }

        // Test font generation
        do {
            _ = await FontService.shared.generateFont(
                family: configuration.fontFamily,
                size: configuration.fontSize
            )
        } catch {
            errors.append(.fontGenerationFailed(configuration.fontFamily.displayName))
        }

        return errors
    }
}

// MARK: - Image Generation Errors
enum ImageGenerationError: LocalizedError, Equatable {
    case emptyText
    case textTooLong
    case contextCreationFailed
    case dataConversionFailed
    case fontGenerationFailed(String)
    case invalidPadding
    case invalidMaxWidth
    case invalidLineHeight

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "文本不能为空"
        case .textTooLong:
            return "文本过长（最多10000字符）"
        case .contextCreationFailed:
            return "无法创建图形上下文"
        case .dataConversionFailed:
            return "图片数据转换失败"
        case .fontGenerationFailed(let fontName):
            return "字体生成失败：\(fontName)"
        case .invalidPadding:
            return "边距值无效（范围：0-100）"
        case .invalidMaxWidth:
            return "最大宽度无效（范围：100-4000）"
        case .invalidLineHeight:
            return "行高无效（范围：0.5-5.0）"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .emptyText:
            return "请输入一些文本"
        case .textTooLong:
            return "请缩短文本内容"
        case .contextCreationFailed:
            return "请重启应用程序"
        case .dataConversionFailed:
            return "请尝试不同的配置"
        case .fontGenerationFailed:
            return "请选择系统字体"
        case .invalidPadding, .invalidMaxWidth, .invalidLineHeight:
            return "请检查配置值"
        }
    }
}