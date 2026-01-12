import Foundation
import SwiftUI

/// Quality mode for frame rate
enum FrameRateMode: String, CaseIterable {
    case fixed = "fixed"
    case relative = "relative"
    
    var displayName: String {
        switch self {
        case .fixed: return "Fixed value"
        case .relative: return "Relative to original"
        }
    }
}

/// Quality mode for resolution
enum ResolutionMode: String, CaseIterable {
    case fixed = "fixed"
    case relative = "relative"
    
    var displayName: String {
        switch self {
        case .fixed: return "Fixed width"
        case .relative: return "Relative to original"
        }
    }
}

/// Manager for application settings, persisted using UserDefaults
class SettingsManager: ObservableObject {
    /// Shared singleton instance
    static let shared = SettingsManager()
    
    // MARK: - Output Location Settings
    
    /// Whether to save GIFs in the same folder as the source video
    @AppStorage("saveToSameFolder") var saveToSameFolder: Bool = true
    
    /// Custom output directory path (used when saveToSameFolder is false)
    @AppStorage("customOutputPath") var customOutputPath: String = ""
    
    /// Recent location paths (stored as JSON array)
    @AppStorage("recentLocationPaths") var recentLocationPathsJSON: String = "[]"
    
    /// Maximum number of recent locations to keep
    private let maxRecentLocations = 10
    
    /// Returns the custom output directory URL, defaulting to Desktop if not set
    var customOutputURL: URL {
        if customOutputPath.isEmpty {
            return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
        }
        return URL(fileURLWithPath: customOutputPath)
    }
    
    /// Get recent location URLs
    var recentLocations: [URL] {
        guard let data = recentLocationPathsJSON.data(using: .utf8),
              let paths = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return paths.compactMap { URL(fileURLWithPath: $0) }
            .filter { FileManager.default.fileExists(atPath: $0.path) }
    }
    
    /// Add a location to recent history
    func addToRecentLocations(_ url: URL) {
        var paths = recentLocations.map { $0.path }
        
        // Remove if already exists (will be re-added at top)
        paths.removeAll { $0 == url.path }
        
        // Add at beginning
        paths.insert(url.path, at: 0)
        
        // Keep only max items
        if paths.count > maxRecentLocations {
            paths = Array(paths.prefix(maxRecentLocations))
        }
        
        // Save as JSON
        if let data = try? JSONEncoder().encode(paths),
           let json = String(data: data, encoding: .utf8) {
            recentLocationPathsJSON = json
        }
    }
    
    /// Clear recent locations
    func clearRecentLocations() {
        recentLocationPathsJSON = "[]"
    }
    
    // MARK: - Frame Rate Settings
    
    /// Frame rate mode
    @AppStorage("frameRateMode") var frameRateModeRaw: String = FrameRateMode.relative.rawValue
    
    var frameRateMode: FrameRateMode {
        get { FrameRateMode(rawValue: frameRateModeRaw) ?? .relative }
        set { frameRateModeRaw = newValue.rawValue }
    }
    
    /// Fixed frame rate value (used when mode is .fixed)
    @AppStorage("fixedFrameRate") var fixedFrameRate: Int = 25
    
    /// Relative frame rate multiplier (used when mode is .relative)
    @AppStorage("relativeFrameRate") var relativeFrameRate: Double = 0.5
    
    // MARK: - Resolution Settings
    
    /// Resolution mode
    @AppStorage("resolutionMode") var resolutionModeRaw: String = ResolutionMode.relative.rawValue
    
    var resolutionMode: ResolutionMode {
        get { ResolutionMode(rawValue: resolutionModeRaw) ?? .relative }
        set { resolutionModeRaw = newValue.rawValue }
    }
    
    /// Fixed width value (used when mode is .fixed)
    @AppStorage("fixedWidth") var fixedWidth: Int = 800
    
    /// Relative resolution multiplier (used when mode is .relative)
    @AppStorage("relativeResolution") var relativeResolution: Double = 1.0
    
    // MARK: - Debug Settings
    
    /// Whether debug mode is enabled
    @AppStorage("debugModeEnabled") var debugModeEnabled: Bool = false
    
    /// Trigger to show debug window (incremented to trigger)
    @Published var showDebugWindowTrigger: Int = 0
    
    /// Trigger to show about window (incremented to trigger)
    @Published var showAboutWindowTrigger: Int = 0
    
    /// Request to show the debug window
    func requestShowDebugWindow() {
        showDebugWindowTrigger += 1
    }
    
    /// Request to show the about window
    func requestShowAboutWindow() {
        showAboutWindowTrigger += 1
    }
    
    // MARK: - Methods
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    /// Get the output directory for a given input file
    /// - Parameter inputURL: The input video file URL
    /// - Returns: The directory where the output GIF should be saved
    func outputDirectory(for inputURL: URL) -> URL? {
        if saveToSameFolder {
            return nil // GifConverter will use input file's directory
        } else {
            return customOutputURL
        }
    }
    
    /// Set the custom output path from a URL
    /// - Parameter url: The directory URL to save to
    func setCustomOutputPath(_ url: URL) {
        customOutputPath = url.path
        addToRecentLocations(url)
    }
    
    /// Calculate the actual frame rate to use based on settings and original video
    /// - Parameter originalFps: The original video's frame rate
    /// - Returns: The frame rate to use for the GIF
    func calculateFrameRate(from originalFps: Double) -> Int {
        switch frameRateMode {
        case .fixed:
            return max(1, fixedFrameRate)
        case .relative:
            return max(1, Int((originalFps * relativeFrameRate).rounded()))
        }
    }
    
    /// Calculate the actual width to use based on settings and original video
    /// - Parameter originalWidth: The original video's width
    /// - Returns: The width to use for the GIF
    func calculateWidth(from originalWidth: Int) -> Int {
        switch resolutionMode {
        case .fixed:
            return max(1, fixedWidth)
        case .relative:
            return max(1, Int((Double(originalWidth) * relativeResolution).rounded()))
        }
    }
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        saveToSameFolder = true
        customOutputPath = ""
        frameRateModeRaw = FrameRateMode.relative.rawValue
        fixedFrameRate = 25
        relativeFrameRate = 1.0
        resolutionModeRaw = ResolutionMode.relative.rawValue
        fixedWidth = 800
        relativeResolution = 1.0
        debugModeEnabled = false
    }
}
