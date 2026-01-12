import SwiftUI
import UniformTypeIdentifiers

/// View displayed after successful GIF conversion
struct CompletionView: View {
    /// The output GIF file URL
    let outputURL: URL
    
    /// Callback when user wants to convert another video
    let onConvertAnother: () -> Void
    
    /// Callback when user drops a new video file
    let onVideoSelected: (URL) -> Void
    
    /// Animation state for success checkmark
    @State private var showCheckmark = false
    @State private var checkmarkScale: CGFloat = 0.5
    
    /// Hover state for drop zone
    @State private var isTargeted = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                    .scaleEffect(checkmarkScale)
                    .opacity(showCheckmark ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showCheckmark = true
                    checkmarkScale = 1.0
                }
            }
            
            // Success message
            VStack(spacing: 8) {
                Text("Conversion Complete!")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text(FileNaming.displayName(for: outputURL))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Text(FileNaming.shortenedPath(for: outputURL.deletingLastPathComponent()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: openInFinder) {
                    Label("Show in Finder", systemImage: "folder")
                }
                .buttonStyle(.bordered)
                
                Button(action: previewGIF) {
                    Label("Preview", systemImage: "eye")
                }
                .buttonStyle(.borderedProminent)
            }
            
            Divider()
                .padding(.horizontal, 40)
            
            // Drop zone for another file
            VStack(spacing: 8) {
                Text("Drop another video here")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1, dash: [4])
                    )
                    .foregroundColor(isTargeted ? .accentColor : .secondary.opacity(0.3))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isTargeted ? Color.accentColor.opacity(0.05) : Color.clear)
                    )
                    .frame(height: 50)
                    .overlay(
                        HStack {
                            Image(systemName: "film")
                                .foregroundColor(.secondary)
                            Text("or click to browse")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        openFilePicker()
                    }
                    .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                        handleDrop(providers: providers)
                        return true
                    }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
    
    /// Open the output folder in Finder
    private func openInFinder() {
        NSWorkspace.shared.selectFile(outputURL.path, inFileViewerRootedAtPath: outputURL.deletingLastPathComponent().path)
    }
    
    /// Preview the GIF in the default app
    private func previewGIF() {
        NSWorkspace.shared.open(outputURL)
    }
    
    /// Open the file picker dialog
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.movie, .video, .quickTimeMovie, .mpeg, .mpeg4Movie]
        panel.message = "Select a video file to convert to GIF"
        panel.prompt = "Convert"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                if FileNaming.isVideoFile(url) {
                    onVideoSelected(url)
                }
            }
        }
    }
    
    /// Handle file drop
    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            if FileNaming.isVideoFile(url) {
                DispatchQueue.main.async {
                    onVideoSelected(url)
                }
            }
        }
    }
}

#Preview {
    CompletionView(
        outputURL: URL(fileURLWithPath: "/Users/test/Desktop/video.gif"),
        onConvertAnother: {},
        onVideoSelected: { _ in }
    )
    .frame(width: 400, height: 400)
}

