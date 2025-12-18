import Foundation
import AppKit
import ComposableArchitecture

// MARK: - Dependency System
// Modern Swift: protocol-based dependency injection for testable architecture

// MARK: - Live Dependencies

struct FontConfigManagerKey: DependencyKey {
    static let liveValue: any FontConfigManaging = ModernFontConfigurationManager.shared
}

struct FontServiceKey: DependencyKey {
    static let liveValue: FontService = FontService.shared
}

struct FontPreviewGeneratorKey: DependencyKey {
    static let liveValue: FontPreviewGenerator = FontPreviewGenerator.shared
}

struct FontMetricsCalculatorKey: DependencyKey {
    static let liveValue: FontMetricsCalculator = FontMetricsCalculator.shared
}

struct ImageGeneratorKey: DependencyKey {
    static let liveValue: any ImageGenerating = ImageGenerator.shared
}

struct ImageFileManagerKey: DependencyKey {
    static let liveValue: any ImageFileManaging = ImageFileManager.shared
}

// MARK: - Test Dependencies
// These use mock implementations for proper unit testing isolation

extension FontConfigManagerKey: TestDependencyKey {
    @MainActor
    static var testValue: any FontConfigManaging {
        MockFontConfigManager()
    }
}

extension FontServiceKey: TestDependencyKey {
    static var testValue: FontService {
        FontService.shared
    }
}

extension FontPreviewGeneratorKey: TestDependencyKey {
    static var testValue: FontPreviewGenerator {
        FontPreviewGenerator.shared
    }
}

extension FontMetricsCalculatorKey: TestDependencyKey {
    static var testValue: FontMetricsCalculator {
        FontMetricsCalculator.shared
    }
}

extension ImageGeneratorKey: TestDependencyKey {
    static var testValue: any ImageGenerating {
        MockImageGenerator()
    }
}

extension ImageFileManagerKey: TestDependencyKey {
    static var testValue: any ImageFileManaging {
        MockImageFileManager()
    }
}
