import SwiftUI
import UniformTypeIdentifiers

/// A view that provides drag-and-drop and click-to-browse functionality for video files
struct DropZoneView: View {
    /// Callback when a video file is selected
    let onVideoSelected: (URL) -> Void
    
    /// Whether the view is currently being hovered over with a file
    @State private var isTargeted = false
    
    /// Error message to display for invalid files
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "film")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.accentColor)
            }
            .scaleEffect(isTargeted ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: isTargeted)
            
            // Instructions
            VStack(spacing: 8) {
                Text("Drop video here")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("or click to browse")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Supported formats hint
            Text("Supports MOV, MP4, AVI, MKV, and more")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .foregroundColor(isTargeted ? .accentColor : .secondary.opacity(0.3))
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isTargeted ? Color.accentColor.opacity(0.05) : Color.clear)
        )
        .contentShape(Rectangle())
        .focusable()
        .onTapGesture {
            openFilePicker()
        }
        .modifier(KeyboardShortcutModifier(action: openFilePicker))
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
        .padding(20)
    }
    
    /// Modifier for keyboard accessibility (macOS 14+)
    struct KeyboardShortcutModifier: ViewModifier {
        let action: () -> Void
        
        func body(content: Content) -> some View {
            if #available(macOS 14.0, *) {
                content
                    .onKeyPress(.space) {
                        action()
                        return .handled
                    }
                    .onKeyPress(.return) {
                        action()
                        return .handled
                    }
            } else {
                content
            }
        }
    }
    
    /// Handle file drop
    private func handleDrop(providers: [NSItemProvider]) {
        errorMessage = nil
        
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                DispatchQueue.main.async {
                    errorMessage = "Could not read the dropped file."
                }
                return
            }
            
            processFile(url: url)
        }
    }
    
    /// Open the file picker dialog
    private func openFilePicker() {
        errorMessage = nil
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = videoContentTypes
        panel.message = "Select a video file to convert to GIF"
        panel.prompt = "Convert"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                processFile(url: url)
            }
        }
    }
    
    /// Process the selected file
    private func processFile(url: URL) {
        // Check if it's a video file
        guard FileNaming.isVideoFile(url) else {
            DispatchQueue.main.async {
                errorMessage = "Please select a video file."
            }
            return
        }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            DispatchQueue.main.async {
                errorMessage = "File not found."
            }
            return
        }
        
        DispatchQueue.main.async {
            errorMessage = nil
            onVideoSelected(url)
        }
    }
    
    /// Supported video content types for the file picker
    private var videoContentTypes: [UTType] {
        [
            .movie,
            .video,
            .quickTimeMovie,
            .mpeg,
            .mpeg4Movie,
            .avi,
            UTType(filenameExtension: "mkv") ?? .movie,
            UTType(filenameExtension: "webm") ?? .movie,
            UTType(filenameExtension: "flv") ?? .movie,
            UTType(filenameExtension: "wmv") ?? .movie,
        ]
    }
}

#Preview {
    DropZoneView { url in
        print("Selected: \(url)")
    }
    .frame(width: 400, height: 350)
}

