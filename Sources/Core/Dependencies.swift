import ComposableArchitecture

// MARK: - Dependency System
// Modern Swift: dependency injection, testable architecture

struct FontConfigManagerKey: DependencyKey {
    var liveValue: ModernFontConfigurationManager {
        ModernFontConfigurationManager.shared
    }
}

struct FontServiceKey: DependencyKey {
    var liveValue: FontService {
        FontService.shared
    }
}

struct FontPreviewGeneratorKey: DependencyKey {
    var liveValue: FontPreviewGenerator {
        FontPreviewGenerator.shared
    }
}

struct FontMetricsCalculatorKey: DependencyKey {
    var liveValue: FontMetricsCalculator {
        FontMetricsCalculator.shared
    }
}

struct ImageGeneratorKey: DependencyKey {
    var liveValue: ImageGenerator {
        ImageGenerator.shared
    }
}

struct ImageFileManagerKey: DependencyKey {
    var liveValue: ImageFileManager {
        ImageFileManager.shared
    }
}

// MARK: - Test Dependencies (for future unit testing)
extension FontConfigManagerKey: TestDependencyKey {
    var testValue: ModernFontConfigurationManager {
        MockFontConfigurationManager()
    }
}

extension FontServiceKey: TestDependencyKey {
    var testValue: FontService {
        MockFontService()
    }
}

extension FontPreviewGeneratorKey: TestDependencyKey {
    var testValue: FontPreviewGenerator {
        MockFontPreviewGenerator()
    }
}

extension FontMetricsCalculatorKey: TestDependencyKey {
    var testValue: FontMetricsCalculator {
        MockFontMetricsCalculator()
    }
}

extension ImageGeneratorKey: TestDependencyKey {
    var testValue: ImageGenerator {
        MockImageGenerator()
    }
}

extension ImageFileManagerKey: TestDependencyKey {
    var testValue: ImageFileManager {
        MockImageFileManager()
    }
}

// MARK: - Mock Implementations (for testing)
class MockFontConfigurationManager: ModernFontConfigurationManager {
    override func updateConfiguration(_ config: ExportConfiguration) {
        // Mock implementation
    }

    override func validateConfiguration(_ config: ExportConfiguration) -> [ConfigurationError] {
        return []
    }
}

class MockFontService: FontService {
    override func generateFont(
        family: ModernFontFamily,
        size: ModernFontSize,
        weight: NSFont.Weight = .medium
    ) async -> NSFont {
        return NSFont.systemFont(ofSize: size.pointSize, weight: weight)
    }
}

class MockFontPreviewGenerator: FontPreviewGenerator {
    override func generatePreview(
        for text: String,
        with config: ExportConfiguration
    ) async throws -> NSImage {
        return NSImage(size: NSSize(width: 400, height: 200))
    }
}

class MockFontMetricsCalculator: FontMetricsCalculator {
    override func calculateOptimalImageSize(
        for text: String,
        with config: ExportConfiguration,
        font: NSFont
    ) async -> CGSize {
        return CGSize(width: 400, height: 200)
    }
}

class MockImageGenerator: ImageGenerator {
    override func generateImage(
        from text: String,
        with configuration: ExportConfiguration
    ) async throws -> Data {
        // Return a simple test image data
        return Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) // PNG header
    }
}

class MockImageFileManager: ImageFileManager {
    override func exportWithSaveDialog(_ imageData: Data) async throws -> URL? {
        // Mock implementation - just return nil
        return nil
    }

    override func saveHistoryItem(_ item: HistoryItemData) async throws {
        // Mock implementation - do nothing
    }
}

// MARK: - Dependency Container
@globalActor
class DependencyContainer {
    static let shared = DependencyContainer()

    private var dependencies: [ObjectIdentifier: Any] = [:]

    func register<T>(_ key: T.Type, value: T) {
        dependencies[ObjectIdentifier(T.self)] = value
    }

    func resolve<T>(_ key: T.Type) -> T {
        return dependencies[ObjectIdentifier(T.self)] as! T
    }
}