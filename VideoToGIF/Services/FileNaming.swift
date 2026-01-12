import Foundation

/// Service responsible for handling file naming and collision resolution
enum FileNaming {
    /// Generate a unique output URL for the GIF file
    /// If the file already exists, appends a numeric suffix: video (1).gif, video (2).gif, etc.
    /// - Parameters:
    ///   - inputURL: The URL of the input video file
    ///   - outputDirectory: Optional custom output directory. If nil, uses the same directory as input.
    /// - Returns: A unique URL for the output GIF file
    static func uniqueOutputURL(for inputURL: URL, in outputDirectory: URL? = nil) -> URL {
        let directory = outputDirectory ?? inputURL.deletingLastPathComponent()
        let baseName = inputURL.deletingPathExtension().lastPathComponent
        let targetExtension = "gif"
        
        var outputURL = directory.appendingPathComponent(baseName).appendingPathExtension(targetExtension)
        
        // If file doesn't exist, use the original name
        if !FileManager.default.fileExists(atPath: outputURL.path) {
            return outputURL
        }
        
        // Find a unique name with numeric suffix
        var counter = 1
        while FileManager.default.fileExists(atPath: outputURL.path) {
            let newName = "\(baseName) (\(counter))"
            outputURL = directory.appendingPathComponent(newName).appendingPathExtension(targetExtension)
            counter += 1
            
            // Safety limit to prevent infinite loop
            if counter > 1000 {
                // Fallback to timestamp-based name
                let timestamp = Int(Date().timeIntervalSince1970)
                let fallbackName = "\(baseName)_\(timestamp)"
                return directory.appendingPathComponent(fallbackName).appendingPathExtension(targetExtension)
            }
        }
        
        return outputURL
    }
    
    /// Check if a URL points to a valid video file
    /// - Parameter url: The URL to check
    /// - Returns: True if the file appears to be a video
    static func isVideoFile(_ url: URL) -> Bool {
        let videoExtensions = [
            "mov", "mp4", "m4v", "avi", "mkv", "wmv", "flv", "webm",
            "mpeg", "mpg", "3gp", "3g2", "mts", "m2ts", "ts", "vob"
        ]
        
        let ext = url.pathExtension.lowercased()
        return videoExtensions.contains(ext)
    }
    
    /// Get the display name for a file (without path, with extension)
    /// - Parameter url: The file URL
    /// - Returns: The display name
    static func displayName(for url: URL) -> String {
        return url.lastPathComponent
    }
    
    /// Get a shortened display path (useful for UI)
    /// - Parameter url: The file URL
    /// - Returns: A shortened path with ~ for home directory
    static func shortenedPath(for url: URL) -> String {
        var path = url.path
        
        // Replace home directory with ~
        if let homeDir = FileManager.default.homeDirectoryForCurrentUser.path.removingPercentEncoding {
            path = path.replacingOccurrences(of: homeDir, with: "~")
        }
        
        return path
    }
}

