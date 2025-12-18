import Foundation
import AppKit

// MARK: - Image File Manager
// Modern Swift features: async/await, result types, file management

actor ImageFileManager {
    static let shared = ImageFileManager()

    private let documentsDirectory: URL
    private let imagesDirectory: URL
    private let historyFile: URL

    private init() {
        // Get documents directory
        documentsDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("TextToShare")

        // Create images directory
        imagesDirectory = documentsDirectory.appendingPathComponent("GeneratedImages")

        // History file path
        historyFile = documentsDirectory.appendingPathComponent("history.json")

        Task {
            await setupDirectories()
        }
    }

    // MARK: - Directory Setup
    private func setupDirectories() async {
        let fileManager = FileManager.default

        do {
            // Create main directory
            try fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)

            // Create images directory
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        } catch {
            print("Failed to create directories: \(error)")
        }
    }

    // MARK: - Image Export
    func exportImage(_ imageData: Data, suggestedName: String? = nil) async throws -> URL {
        let fileName = suggestedName ?? generateFileName()
        let fileURL = imagesDirectory.appendingPathComponent(fileName)

        try imageData.write(to: fileURL)
        return fileURL
    }

    // MARK: - Save Panel Export
    func exportWithSaveDialog(_ imageData: Data) async throws -> URL? {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let savePanel = NSSavePanel()
                savePanel.allowedContentTypes = [.png]
                savePanel.nameFieldStringValue = self.generateFileName()

                savePanel.begin { response in
                    if response == .OK, let url = savePanel.url {
                        do {
                            try imageData.write(to: url)
                            continuation.resume(returning: url)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }

    // MARK: - History Management
    func saveHistoryItem(_ item: HistoryItemData) async throws {
        var history = try await loadHistory()
        history.items.insert(item, at: 0)

        // Keep only last 100 items
        if history.items.count > 100 {
            history.items = Array(history.items.prefix(100))
        }

        try await saveHistory(history)
    }

    func loadHistory() async throws -> HistoryData {
        guard FileManager.default.fileExists(atPath: historyFile.path) else {
            return HistoryData(items: [])
        }

        let data = try Data(contentsOf: historyFile)
        return try JSONDecoder().decode(HistoryData.self, from: data)
    }

    func clearHistory() async throws {
        let emptyHistory = HistoryData(items: [])
        try await saveHistory(emptyHistory)

        // Also remove all image files
        let fileManager = FileManager.default
        if let enumerator = fileManager.enumerator(at: imagesDirectory, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                try fileManager.removeItem(at: fileURL)
            }
        }
    }

    func removeFromHistory(id: UUID) async throws {
        var history = try await loadHistory()
        history.items.removeAll { $0.id == id }

        try await saveHistory(history)
    }

    // MARK: - Private Helper Functions
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let timestamp = formatter.string(from: Date())
        return "text-to-image-\(timestamp).png"
    }

    private func saveHistory(_ history: HistoryData) async throws {
        let data = try JSONEncoder().encode(history)
        try data.write(to: historyFile)
    }

    // MARK: - File Validation
    func validateImageData(_ data: Data) -> Bool {
        // Simple PNG validation
        return data.count >= 8 &&
               data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47 &&
               data[4] == 0x0D && data[5] == 0x0A && data[6] == 0x1A && data[7] == 0x0A
    }

    func getImageSize(for data: Data) -> CGSize? {
        guard validateImageData(data) else { return nil }

        // Simple PNG size extraction
        if data.count >= 24 {
            let width = UInt32(data[16]) << 24 | UInt32(data[17]) << 16 | UInt32(data[18]) << 8 | UInt32(data[19])
            let height = UInt32(data[20]) << 24 | UInt32(data[21]) << 16 | UInt32(data[22]) << 8 | UInt32(data[23])
            return CGSize(width: CGFloat(width), height: CGFloat(height))
        }

        return nil
    }

    // MARK: - Cleanup
    func cleanupOldFiles(olderThan days: Int = 30) async throws {
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(days * 24 * 60 * 60))
        let fileManager = FileManager.default

        if let enumerator = fileManager.enumerator(at: imagesDirectory, includingPropertiesForKeys: [.creationDateKey]) {
            for case let fileURL as URL in enumerator {
                do {
                    let attributes = try fileURL.resourceValues(forKeys: [.creationDateKey])
                    if let creationDate = attributes.creationDate, creationDate < cutoffDate {
                        try fileManager.removeItem(at: fileURL)
                        print("Removed old file: \(fileURL.lastPathComponent)")
                    }
                } catch {
                    print("Failed to process file \(fileURL.lastPathComponent): \(error)")
                }
            }
        }
    }
}

// MARK: - Data Models
struct HistoryData: Codable {
    var items: [HistoryItemData]
}

struct HistoryItemData: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let imageData: Data
    let createdAt: Date
    let configuration: ExportConfiguration
    let isFavorite: Bool

    init(
        id: UUID = UUID(),
        text: String,
        imageData: Data,
        configuration: ExportConfiguration,
        isFavorite: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.imageData = imageData
        self.createdAt = createdAt
        self.configuration = configuration
        self.isFavorite = isFavorite
    }
}

// MARK: - File Manager Errors
enum ImageFileError: LocalizedError {
    case directoryCreationFailed
    case fileWriteFailed(URL)
    case fileReadFailed(URL)
    case invalidImageData
    case historyCorrupted

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            return "无法创建目录"
        case .fileWriteFailed(let url):
            return "无法写入文件：\(url.lastPathComponent)"
        case .fileReadFailed(let url):
            return "无法读取文件：\(url.lastPathComponent)"
        case .invalidImageData:
            return "图片数据无效"
        case .historyCorrupted:
            return "历史记录已损坏"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .directoryCreationFailed:
            return "请检查磁盘权限"
        case .fileWriteFailed, .fileReadFailed:
            return "请检查文件权限和磁盘空间"
        case .invalidImageData:
            return "请重新生成图片"
        case .historyCorrupted:
            return "历史记录将被重置"
        }
    }
}