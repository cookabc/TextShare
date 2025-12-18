import Foundation
import AppKit
import ComposableArchitecture

// MARK: - Dependency System
// Modern Swift: dependency injection, testable architecture

struct FontConfigManagerKey: DependencyKey {
    static let liveValue: ModernFontConfigurationManager = ModernFontConfigurationManager.shared
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
    static let liveValue: ImageGenerator = ImageGenerator.shared
}

struct ImageFileManagerKey: DependencyKey {
    static let liveValue: ImageFileManager = ImageFileManager.shared
}

// MARK: - Test Dependencies
extension FontConfigManagerKey: TestDependencyKey {
    static var testValue: ModernFontConfigurationManager {
        ModernFontConfigurationManager.shared
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
    static var testValue: ImageGenerator {
        ImageGenerator.shared
    }
}

extension ImageFileManagerKey: TestDependencyKey {
    static var testValue: ImageFileManager {
        ImageFileManager.shared
    }
}

