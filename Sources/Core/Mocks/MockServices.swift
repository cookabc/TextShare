import Foundation
import AppKit

// MARK: - Mock Implementations for Testing

/// Mock image generator for unit tests
actor MockImageGenerator: ImageGenerating {
    var generateImageResult: Result<Data, Error> = .success(Data([0x89, 0x50, 0x4E, 0x47])) // PNG header
    var generateThemePreviewsResult: [ModernTheme: Data] = [:]
    var validationErrors: [ImageGenerationError] = []
    
    // Track calls for verification
    private(set) var generateImageCallCount = 0
    private(set) var lastGeneratedText: String?
    private(set) var lastConfiguration: ExportConfiguration?
    
    func generateImage(from text: String, with configuration: ExportConfiguration) async throws -> Data {
        generateImageCallCount += 1
        lastGeneratedText = text
        lastConfiguration = configuration
        return try generateImageResult.get()
    }
    
    func generateThemePreviews(for text: String, baseConfiguration: ExportConfiguration) async -> [ModernTheme: Data] {
        return generateThemePreviewsResult
    }
    
    func validateGenerationRequest(text: String, configuration: ExportConfiguration) async -> [ImageGenerationError] {
        return validationErrors
    }
    
    // Test helpers
    func reset() {
        generateImageCallCount = 0
        lastGeneratedText = nil
        lastConfiguration = nil
        generateImageResult = .success(Data([0x89, 0x50, 0x4E, 0x47]))
        generateThemePreviewsResult = [:]
        validationErrors = []
    }
    
    func setFailure(_ error: ImageGenerationError) {
        generateImageResult = .failure(error)
    }
}

/// Mock file manager for unit tests
actor MockImageFileManager: ImageFileManaging {
    var historyItems: [HistoryItemData] = []
    var shouldFailOnSave = false
    var shouldFailOnLoad = false
    var exportedURL: URL?
    
    // Track calls for verification
    private(set) var saveCallCount = 0
    private(set) var loadCallCount = 0
    private(set) var removeCallCount = 0
    private(set) var clearCallCount = 0
    private(set) var exportCallCount = 0
    
    func saveHistoryItem(_ item: HistoryItemData) async throws {
        saveCallCount += 1
        if shouldFailOnSave {
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock save failure"])
        }
        historyItems.insert(item, at: 0)
    }
    
    func loadHistory() async throws -> HistoryData {
        loadCallCount += 1
        if shouldFailOnLoad {
            throw NSError(domain: "MockError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Mock load failure"])
        }
        return HistoryData(items: historyItems)
    }
    
    func removeFromHistory(id: UUID) async throws {
        removeCallCount += 1
        historyItems.removeAll { $0.id == id }
    }
    
    func clearHistory() async throws {
        clearCallCount += 1
        historyItems.removeAll()
    }
    
    func exportWithSaveDialog(_ imageData: Data) async throws -> URL? {
        exportCallCount += 1
        let url = URL(fileURLWithPath: "/tmp/mock-export-\(UUID().uuidString).png")
        exportedURL = url
        return url
    }
    
    // Test helpers
    func reset() {
        historyItems = []
        shouldFailOnSave = false
        shouldFailOnLoad = false
        exportedURL = nil
        saveCallCount = 0
        loadCallCount = 0
        removeCallCount = 0
        clearCallCount = 0
        exportCallCount = 0
    }
    
    func addMockHistoryItem(text: String = "Test text") {
        let item = HistoryItemData(
            text: text,
            imageData: Data([0x89, 0x50, 0x4E, 0x47]),
            configuration: .default
        )
        historyItems.append(item)
    }
}

/// Mock font configuration manager for unit tests
@MainActor
final class MockFontConfigManager: FontConfigManaging {
    var currentConfig: ExportConfiguration = .default
    var recentConfigs: [ExportConfiguration] = []
    var favoriteConfigs: [ExportConfiguration] = []
    var validationErrors: [ConfigurationError] = []
    
    // Track calls
    private(set) var updateCallCount = 0
    private(set) var resetCallCount = 0
    private(set) var applyPresetCallCount = 0
    
    func updateConfiguration(_ config: ExportConfiguration) {
        updateCallCount += 1
        currentConfig = config
    }
    
    func resetToDefault() {
        resetCallCount += 1
        currentConfig = .default
    }
    
    func applyPreset(_ preset: ExportConfigurationPreset) {
        applyPresetCallCount += 1
        switch preset {
        case .default: currentConfig = .default
        case .codeFocused: currentConfig = .codeFocused
        case .presentation: currentConfig = .presentation
        case .minimal: currentConfig = .minimal
        }
    }
    
    func addToFavorites(_ config: ExportConfiguration) {
        if !favoriteConfigs.contains(config) {
            favoriteConfigs.append(config)
        }
    }
    
    func removeFromFavorites(_ config: ExportConfiguration) {
        favoriteConfigs.removeAll { $0 == config }
    }
    
    func validateConfiguration(_ config: ExportConfiguration) -> [ConfigurationError] {
        return validationErrors
    }
    
    func clearRecentConfigs() {
        recentConfigs.removeAll()
    }
    
    // Test helpers
    func reset() {
        currentConfig = .default
        recentConfigs = []
        favoriteConfigs = []
        validationErrors = []
        updateCallCount = 0
        resetCallCount = 0
        applyPresetCallCount = 0
    }
}
