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