import SwiftUI

/// A window that displays real-time FFmpeg command output for debugging
struct DebugWindowView: View {
    /// The GIF converter instance to observe
    @ObservedObject var converter: GifConverter
    
    /// Whether to auto-scroll to the bottom
    @State private var autoScroll = true
    
    /// Reference to scroll view for programmatic scrolling
    @State private var scrollViewProxy: ScrollViewProxy?
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("FFmpeg Output")
                    .font(.headline)
                
                Spacer()
                
                Toggle("Auto-scroll", isOn: $autoScroll)
                    .toggleStyle(.checkbox)
                    .font(.caption)
                
                Button(action: clearLog) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Clear log")
                
                Button(action: copyLog) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
                .help("Copy to clipboard")
            }
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Log output
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(converter.debugOutput) { entry in
                            HStack(alignment: .top, spacing: 8) {
                                Text(entry.formattedTimestamp)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 90, alignment: .leading)
                                
                                Text(entry.message)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(colorForMessage(entry.message))
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .id(entry.id)
                        }
                    }
                    .padding(12)
                }
                .background(Color(nsColor: .textBackgroundColor))
                .onChange(of: converter.debugOutput.count) { _ in
                    if autoScroll, let lastEntry = converter.debugOutput.last {
                        withAnimation {
                            proxy.scrollTo(lastEntry.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    scrollViewProxy = proxy
                }
            }
            
            // Status bar
            HStack {
                if converter.debugOutput.isEmpty {
                    Text("Waiting for conversion...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(converter.debugOutput.count) lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(converter.isDebugEnabled ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(converter.isDebugEnabled ? "Debug enabled" : "Debug disabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 500, minHeight: 300)
    }
    
    /// Clear the debug log
    private func clearLog() {
        converter.clearDebugLog()
    }
    
    /// Copy the log to clipboard
    private func copyLog() {
        let logText = converter.debugOutput
            .map { "[\($0.formattedTimestamp)] \($0.message)" }
            .joined(separator: "\n")
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(logText, forType: .string)
    }
    
    /// Get color for log message based on content
    private func colorForMessage(_ message: String) -> Color {
        let lowercased = message.lowercased()
        
        if lowercased.contains("error") || lowercased.contains("failed") {
            return .red
        } else if lowercased.contains("warning") {
            return .orange
        } else if lowercased.contains("success") || lowercased.contains("completed") {
            return .green
        } else if message.hasPrefix("frame=") || message.contains("time=") {
            return .blue
        }
        
        return .primary
    }
}

#Preview {
    let converter = GifConverter()
    converter.isDebugEnabled = true
    
    return DebugWindowView(converter: converter)
        .frame(width: 600, height: 400)
}

