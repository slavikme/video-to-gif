import SwiftUI

/// Settings window for configuring application preferences
struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @State private var showFolderPicker = false
    
    var body: some View {
        TabView {
            // Output Tab
            outputTab
                .tabItem {
                    Label("Output", systemImage: "folder")
                }
            
            // Quality Tab
            qualityTab
                .tabItem {
                    Label("Quality", systemImage: "slider.horizontal.3")
                }
        }
        .padding(20)
        .frame(width: 500, height: 380)
    }
    
    // MARK: - Output Tab
    
    private var outputTab: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle(isOn: $settings.saveToSameFolder) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Same folder as source video")
                                .font(.body)
                            Text("Save the GIF next to the original video file")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(.checkbox)
                    
                    HStack(spacing: 8) {
                        Text("Custom save location:")
                            .foregroundColor(settings.saveToSameFolder ? .secondary : .primary)
                        
                        Text(FileNaming.shortenedPath(for: settings.customOutputURL))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )
                            .help(settings.customOutputURL.path)
                        
                        Button("Browse...") {
                            showFolderPicker = true
                        }
                        .disabled(settings.saveToSameFolder)
                    }
                    .opacity(settings.saveToSameFolder ? 0.5 : 1.0)
                }
            } header: {
                Label("Save Location", systemImage: "folder")
            }
        }
        .formStyle(.grouped)
        .fileImporter(
            isPresented: $showFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                settings.setCustomOutputPath(url)
            }
        }
    }
    
    // MARK: - Quality Tab
    
    private var qualityTab: some View {
        Form {
            // Frame Rate Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Fixed option with inline picker
                    HStack(spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { settings.frameRateMode == .fixed },
                            set: { if $0 { settings.frameRateMode = .fixed } }
                        )) {
                            Text("Fixed value")
                        }
                        .toggleStyle(.radioButton)
                        
                        Spacer()
                        
                        Picker("", selection: $settings.fixedFrameRate) {
                            Text("10 fps").tag(10)
                            Text("15 fps").tag(15)
                            Text("20 fps").tag(20)
                            Text("25 fps").tag(25)
                            Text("30 fps").tag(30)
                            Text("60 fps").tag(60)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                        .disabled(settings.frameRateMode != .fixed)
                        .modifier(HideFocusRing())
                    }
                    
                    // Relative option with inline picker
                    HStack(spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { settings.frameRateMode == .relative },
                            set: { if $0 { settings.frameRateMode = .relative } }
                        )) {
                            Text("Relative to original")
                        }
                        .toggleStyle(.radioButton)
                        
                        Spacer()
                        
                        Picker("", selection: $settings.relativeFrameRate) {
                            Text("0.25× (quarter)").tag(0.25)
                            Text("0.5× (half)").tag(0.5)
                            Text("0.75×").tag(0.75)
                            Text("1× (original)").tag(1.0)
                            Text("1.5×").tag(1.5)
                            Text("2× (double)").tag(2.0)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        .disabled(settings.frameRateMode != .relative)
                        .modifier(HideFocusRing())
                    }
                }
            } header: {
                Label("Frame Rate", systemImage: "film")
            }
            
            // Resolution Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Fixed option with inline picker
                    HStack(spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { settings.resolutionMode == .fixed },
                            set: { if $0 { settings.resolutionMode = .fixed } }
                        )) {
                            Text("Fixed width")
                        }
                        .toggleStyle(.radioButton)
                        
                        Spacer()
                        
                        Picker("", selection: $settings.fixedWidth) {
                            Text("320px").tag(320)
                            Text("480px").tag(480)
                            Text("640px").tag(640)
                            Text("800px").tag(800)
                            Text("1024px").tag(1024)
                            Text("1280px").tag(1280)
                            Text("1920px").tag(1920)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                        .disabled(settings.resolutionMode != .fixed)
                        .modifier(HideFocusRing())
                    }
                    
                    // Relative option with inline picker
                    HStack(spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { settings.resolutionMode == .relative },
                            set: { if $0 { settings.resolutionMode = .relative } }
                        )) {
                            Text("Relative to original")
                        }
                        .toggleStyle(.radioButton)
                        
                        Spacer()
                        
                        Picker("", selection: $settings.relativeResolution) {
                            Text("0.25× (quarter)").tag(0.25)
                            Text("0.5× (half)").tag(0.5)
                            Text("0.75×").tag(0.75)
                            Text("1× (original)").tag(1.0)
                            Text("1.25×").tag(1.25)
                            Text("1.5×").tag(1.5)
                            Text("2× (double)").tag(2.0)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        .disabled(settings.resolutionMode != .relative)
                        .modifier(HideFocusRing())
                    }
                }
            } header: {
                Label("Resolution", systemImage: "aspectratio")
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Radio Button Toggle Style

struct RadioButtonToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        RadioButtonView(configuration: configuration)
    }
}

struct RadioButtonView: View {
    let configuration: ToggleStyleConfiguration
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: configuration.isOn ? "circle.inset.filled" : "circle")
                .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                .font(.system(size: 14))
            
            configuration.label
        }
        .contentShape(Rectangle())
        .focusable()
        .focused($isFocused)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.accentColor, lineWidth: 2)
                .opacity(isFocused ? 1 : 0)
                .padding(-2)
        )
        .onTapGesture {
            configuration.$isOn.wrappedValue = true
        }
        .modifier(RadioButtonKeyboardModifier(action: {
            configuration.$isOn.wrappedValue = true
        }))
    }
}

struct RadioButtonKeyboardModifier: ViewModifier {
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

extension ToggleStyle where Self == RadioButtonToggleStyle {
    static var radioButton: RadioButtonToggleStyle { RadioButtonToggleStyle() }
}

// MARK: - Hide Focus Ring Modifier

struct HideFocusRing: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content
                .focusEffectDisabled()
        } else {
            content
        }
    }
}

// MARK: - NSView wrapper to disable focus ring

struct NoFocusRingPicker<SelectionValue: Hashable, Content: View>: NSViewRepresentable {
    @Binding var selection: SelectionValue
    let content: () -> Content
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

#Preview {
    SettingsView()
}
