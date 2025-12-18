import os
import Foundation

// MARK: - Unified Logging System
// Using Apple's unified logging system (os.Logger) for proper log management

enum AppLogger {
    /// Logger for image generation operations
    static let imageGenerator = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.example.TextToShare",
        category: "ImageGenerator"
    )
    
    /// Logger for history and file management
    static let history = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.example.TextToShare",
        category: "History"
    )
    
    /// Logger for settings and configuration
    static let settings = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.example.TextToShare",
        category: "Settings"
    )
    
    /// Logger for UI operations
    static let ui = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.example.TextToShare",
        category: "UI"
    )
    
    /// Logger for general app lifecycle
    static let app = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.example.TextToShare",
        category: "App"
    )
    
    /// Logger for dependency injection and services
    static let services = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.example.TextToShare",
        category: "Services"
    )
}

// MARK: - Convenience Extensions

extension Logger {
    /// Log a successful operation
    func success(_ message: String) {
        self.info("✅ \(message)")
    }
    
    /// Log a user action
    func action(_ message: String) {
        self.info("👆 \(message)")
    }
    
    /// Log a state change
    func stateChange(_ message: String) {
        self.debug("📊 \(message)")
    }
    
    /// Log performance timing
    func timing(_ operation: String, duration: TimeInterval) {
        self.info("⏱️ \(operation) completed in \(String(format: "%.2f", duration * 1000))ms")
    }
}
