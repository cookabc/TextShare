import ComposableArchitecture
import XCTest
@testable import TextToShare

/// Tests for GenerateFeature reducer
@MainActor
final class GenerateFeatureTests: XCTestCase {
    
    // MARK: - Text Update Tests
    
    func testUpdateText_UpdatesStateAndClearsError() async {
        let store = TestStore(initialState: GenerateFeature.State(error: "Previous error")) {
            GenerateFeature()
        }
        
        await store.send(.updateText("Hello World")) {
            $0.text = "Hello World"
            $0.error = nil
        }
    }
    
    // MARK: - Generate Image Tests
    
    func testGenerateImage_WithEmptyText_ShowsError() async {
        let store = TestStore(initialState: GenerateFeature.State(text: "")) {
            GenerateFeature()
        }
        
        await store.send(.generateImage) {
            $0.error = "请输入一些文本"
        }
    }
    
    func testGenerateImage_WithValidText_StartsGeneration() async {
        let mockGenerator = MockImageGenerator()
        let testImageData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        await mockGenerator.setImageResult(.success(testImageData))
        
        let store = TestStore(initialState: GenerateFeature.State(text: "Test text")) {
            GenerateFeature()
        } withDependencies: {
            $0[ImageGeneratorKey.self] = mockGenerator
        }
        
        await store.send(.generateImage) {
            $0.isGenerating = true
            $0.error = nil
        }
        
        await store.receive(\.imageGenerated) {
            $0.isGenerating = false
            $0.generatedImage = testImageData
            $0.successMessage = "图片生成成功"
        }
    }
    
    func testGenerateImage_OnFailure_ShowsError() async {
        let mockGenerator = MockImageGenerator()
        await mockGenerator.setFailure(.contextCreationFailed)
        
        let store = TestStore(initialState: GenerateFeature.State(text: "Test text")) {
            GenerateFeature()
        } withDependencies: {
            $0[ImageGeneratorKey.self] = mockGenerator
        }
        
        await store.send(.generateImage) {
            $0.isGenerating = true
        }
        
        await store.receive(\.generateFailed) {
            $0.isGenerating = false
            $0.error = ImageGenerationError.contextCreationFailed.localizedDescription
        }
    }
    
    // MARK: - Clear Content Tests
    
    func testClearContent_ResetsAllState() async {
        let store = TestStore(
            initialState: GenerateFeature.State(
                text: "Some text",
                generatedImage: Data([1, 2, 3]),
                error: "Some error",
                successMessage: "Some success"
            )
        ) {
            GenerateFeature()
        }
        
        await store.send(.clearContent) {
            $0.text = ""
            $0.generatedImage = nil
            $0.error = nil
            $0.successMessage = nil
        }
    }
    
    // MARK: - Clear Error Tests
    
    func testClearError_ClearsErrorOnly() async {
        let store = TestStore(
            initialState: GenerateFeature.State(
                text: "Some text",
                error: "Some error"
            )
        ) {
            GenerateFeature()
        }
        
        await store.send(.clearError) {
            $0.error = nil
        }
    }
    
    // MARK: - Export Tests
    
    func testExportImage_WithoutImage_ShowsError() async {
        let store = TestStore(initialState: GenerateFeature.State()) {
            GenerateFeature()
        }
        
        await store.send(.exportImage) {
            $0.error = "没有可导出的图片"
        }
    }
    
    // MARK: - Configuration Tests
    
    func testUpdateConfiguration_UpdatesConfig() async {
        let newConfig = ExportConfiguration(
            fontFamily: .menlo,
            fontSize: .large,
            theme: .dark,
            padding: 50,
            maxWidth: 800
        )
        
        let store = TestStore(initialState: GenerateFeature.State()) {
            GenerateFeature()
        }
        
        await store.send(.updateConfiguration(newConfig)) {
            $0.currentConfig = newConfig
        }
    }
}

// MARK: - Mock Helper Extension

extension MockImageGenerator {
    func setImageResult(_ result: Result<Data, Error>) async {
        self.generateImageResult = result
    }
}
