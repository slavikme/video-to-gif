import SwiftUI

@main
struct VideoToGIFApp: App {
    /// Settings manager
    @StateObject private var settings = SettingsManager.shared
    
    /// GIF converter for debug window
    @StateObject private var converter = GifConverter()
    
    var body: some Scene {
        // Main Window
        WindowGroup {
            ContentView()
                .environmentObject(converter)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 450, height: 420)
        .commands {
            // Replace the default About menu item
            CommandGroup(replacing: .appInfo) {
                Button("About Video to GIF") {
                    settings.requestShowAboutWindow()
                }
            }
            
            // Add Debug menu
            CommandMenu("Debug") {
                Toggle("Enable Debug Mode", isOn: $settings.debugModeEnabled)
                    .keyboardShortcut("D", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Show FFmpeg Output") {
                    settings.requestShowDebugWindow()
                }
                .keyboardShortcut("L", modifiers: [.command, .shift])
                .disabled(!settings.debugModeEnabled)
            }
        }
        
        // Settings Window
        Settings {
            SettingsView()
        }
        
        // Debug Window
        Window("FFmpeg Debug Output", id: "debug-window") {
            DebugWindowView(converter: converter)
        }
        .defaultSize(width: 700, height: 400)
        .keyboardShortcut("L", modifiers: [.command, .shift])
        
        // About Window
        Window("About Video to GIF", id: "about-window") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 300, height: 200)
    }
}

/// About view showing app information and credits
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // App icon from asset catalog
            if let iconImage = NSImage(named: "AppIcon") {
                Image(nsImage: iconImage)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                // Fallback to system app icon
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            
            // App name and version
            VStack(spacing: 4) {
                Text("Video to GIF")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Credits
            VStack(spacing: 8) {
                Text("Created by")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Slavik Meltser")
                    .font(.body)
                    .fontWeight(.medium)
                
                Button(action: openGitHub) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption)
                        Text("GitHub Repository")
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            
            // Copyright
            Text("© 2026 Slavik Meltser. All rights reserved.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .frame(width: 300)
    }
    
    /// Open the GitHub repository
    private func openGitHub() {
        if let url = URL(string: "https://github.com/slavikme/video-to-gif") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview("About") {
    AboutView()
}

