import Foundation
import AppKit

// MARK: - Protocol Abstractions for Dependency Injection
// These protocols enable proper testing and mock implementations

/// Protocol for image generation functionality
protocol ImageGenerating: Sendable {
    /// Generate an image from text with the given configuration
    /// - Parameters:
    ///   - text: The text to render
    ///   - configuration: Export configuration settings
    /// - Returns: PNG image data
    func generateImage(from text: String, with configuration: ExportConfiguration) async throws -> Data
    
    /// Generate preview images for all themes
    /// - Parameters:
    ///   - text: The sample text to render
    ///   - baseConfiguration: Base configuration to use
    /// - Returns: Dictionary mapping themes to image data
    func generateThemePreviews(for text: String, baseConfiguration: ExportConfiguration) async -> [ModernTheme: Data]
    
    /// Validate a generation request before processing
    /// - Parameters:
    ///   - text: The text to validate
    ///   - configuration: The configuration to validate
    /// - Returns: Array of validation errors (empty if valid)
    func validateGenerationRequest(text: String, configuration: ExportConfiguration) async -> [ImageGenerationError]
}

/// Protocol for history and file management
protocol ImageFileManaging: Sendable {
    /// Save a history item
    func saveHistoryItem(_ item: HistoryItemData) async throws
    
    /// Load all history data
    func loadHistory() async throws -> HistoryData
    
    /// Remove a specific item from history
    func removeFromHistory(id: UUID) async throws
    
    /// Clear all history
    func clearHistory() async throws
    
    /// Export image with a save dialog
    func exportWithSaveDialog(_ imageData: Data) async throws -> URL?
}

/// Protocol for font configuration management
@MainActor
protocol FontConfigManaging: AnyObject {
    var currentConfig: ExportConfiguration { get }
    var recentConfigs: [ExportConfiguration] { get }
    var favoriteConfigs: [ExportConfiguration] { get }
    
    func updateConfiguration(_ config: ExportConfiguration)
    func resetToDefault()
    func applyPreset(_ preset: ExportConfigurationPreset)
    func addToFavorites(_ config: ExportConfiguration)
    func removeFromFavorites(_ config: ExportConfiguration)
    func validateConfiguration(_ config: ExportConfiguration) -> [ConfigurationError]
    func clearRecentConfigs()
}

/// Protocol for font service functionality
protocol FontServicing: Sendable {
    func generateFont(family: ModernFontFamily, size: ModernFontSize) async -> NSFont
    func calculateTextSize(for text: String, using font: NSFont, maxWidth: CGFloat, lineHeight: CGFloat) async -> CGSize
}

/// Protocol for font metrics calculation
protocol FontMetricsCalculating: Sendable {
    func calculateOptimalImageSize(for text: String, with configuration: ExportConfiguration, font: NSFont) async -> CGSize
}

/// Protocol for font preview generation
protocol FontPreviewGenerating: Sendable {
    func generatePreview(for family: ModernFontFamily, size: ModernFontSize) async -> NSImage?
}
