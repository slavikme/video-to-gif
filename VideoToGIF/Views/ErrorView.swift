import SwiftUI
import UniformTypeIdentifiers

/// View displayed when GIF conversion fails
struct ErrorView: View {
    /// The error that occurred
    let error: ConversionError
    
    /// Callback to try again / go back to drop zone
    let onTryAgain: () -> Void
    
    /// Callback when user drops a new video file
    let onVideoSelected: (URL) -> Void
    
    /// Whether the full error details are shown
    @State private var showDetails = false
    
    /// Hover state for drop zone
    @State private var isTargeted = false
    
    /// Animation state
    @State private var showIcon = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .scaleEffect(showIcon ? 1.0 : 0.5)
                    .opacity(showIcon ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showIcon = true
                }
            }
            
            // Error message
            VStack(spacing: 8) {
                Text("Conversion Failed")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text(error.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
            }
            
            // Show/Hide details button
            Button(action: { showDetails.toggle() }) {
                HStack(spacing: 4) {
                    Text(showDetails ? "Hide Details" : "Show Details")
                        .font(.caption)
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            
            // Error details (expandable)
            if showDetails {
                ScrollView {
                    Text(error.fullOutput)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                }
                .frame(maxHeight: 150)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: onTryAgain) {
                    Text("Try Again")
                }
                .buttonStyle(.bordered)
                
                Button(action: copyErrorToClipboard) {
                    Label("Copy Error", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
                .padding(.horizontal, 40)
            
            // Drop zone for another file
            VStack(spacing: 8) {
                Text("Or try a different video")
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
                    .frame(height: 44)
                    .overlay(
                        HStack {
                            Image(systemName: "film")
                                .foregroundColor(.secondary)
                            Text("Drop video or click to browse")
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
    
    /// Copy the full error output to clipboard
    private func copyErrorToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(error.fullOutput, forType: .string)
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
    ErrorView(
        error: ConversionError(
            message: "The input file appears to be corrupted or in an unsupported format.",
            fullOutput: "ffmpeg version 7.1\nError opening input: Invalid data found when processing input"
        ),
        onTryAgain: {},
        onVideoSelected: { _ in }
    )
    .frame(width: 400, height: 500)
}

