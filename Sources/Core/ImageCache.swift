import AppKit
import Foundation

// MARK: - Image Cache
// Provides efficient caching for generated images to reduce memory pressure
// and avoid redundant image decoding

actor ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, NSImage>()
    private let dataCache = NSCache<NSString, NSData>()
    
    init() {
        // Configure cache limits
        cache.countLimit = 50  // Max 50 images
        cache.totalCostLimit = 100 * 1024 * 1024  // 100MB
        
        dataCache.countLimit = 20
        dataCache.totalCostLimit = 50 * 1024 * 1024  // 50MB
        
        // Register for memory warnings
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.clearAll()
            }
        }
    }
    
    // MARK: - NSImage Caching
    
    /// Get cached image for a key
    func image(for key: String) -> NSImage? {
        cache.object(forKey: key as NSString)
    }
    
    /// Cache an image with a key
    func setImage(_ image: NSImage, for key: String) {
        let size = Int(image.size.width * image.size.height * 4) // Estimate bytes
        cache.setObject(image, forKey: key as NSString, cost: size)
    }
    
    /// Remove cached image for a key
    func removeImage(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    // MARK: - Data Caching
    
    /// Get cached data for a key
    func data(for key: String) -> Data? {
        dataCache.object(forKey: key as NSString) as Data?
    }
    
    /// Cache data with a key
    func setData(_ data: Data, for key: String) {
        dataCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
    }
    
    /// Remove cached data for a key
    func removeData(for key: String) {
        dataCache.removeObject(forKey: key as NSString)
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached images and data
    func clearAll() {
        cache.removeAllObjects()
        dataCache.removeAllObjects()
        AppLogger.app.info("Image cache cleared")
    }
    
    /// Get cache statistics
    func statistics() -> CacheStatistics {
        CacheStatistics(
            imageCountLimit: cache.countLimit,
            dataCountLimit: dataCache.countLimit
        )
    }
}

// MARK: - Cache Statistics
struct CacheStatistics {
    let imageCountLimit: Int
    let dataCountLimit: Int
}

// MARK: - Cache Key Generation

extension ImageCache {
    /// Generate a cache key from text and configuration
    static func cacheKey(for text: String, configuration: ExportConfiguration) -> String {
        let configHash = "\(configuration.fontFamily.rawValue)-\(configuration.fontSize.rawValue)-\(configuration.theme.rawValue)-\(configuration.padding)-\(configuration.maxWidth)"
        let textHash = text.hashValue
        return "\(textHash)-\(configHash)"
    }
}

// MARK: - Async Image Loading View

import SwiftUI

/// A view that lazy-loads an image from data off the main thread
struct AsyncImageDataView: View {
    let imageData: Data
    let contentMode: ContentMode
    
    @State private var image: NSImage?
    @State private var isLoading = true
    
    init(imageData: Data, contentMode: ContentMode = .fit) {
        self.imageData = imageData
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
                    .font(.largeTitle)
            }
        }
        .task(id: imageData) {
            let key = String(imageData.hashValue)
            
            // Check cache first
            if let cached = await ImageCache.shared.image(for: key) {
                image = cached
                isLoading = false
                return
            }
            
            // Decode off main thread
            isLoading = true
            let decodedImage = await Task.detached(priority: .userInitiated) {
                NSImage(data: imageData)
            }.value
            
            if let decodedImage {
                await ImageCache.shared.setImage(decodedImage, for: key)
                image = decodedImage
            }
            
            isLoading = false
        }
    }
}
