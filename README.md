# Video to GIF

A native macOS app that converts videos to high-quality GIFs using FFmpeg. Built with SwiftUI.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

<img width="562" height="581" alt="image" src="https://github.com/user-attachments/assets/11b0feec-99fb-4992-8efc-2f1956929e5c" />
<img width="562" height="581" alt="image" src="https://github.com/user-attachments/assets/f8c5d1ed-b37a-4b83-b8ba-6474a8cc65e9" />
<img width="562" height="596" alt="image" src="https://github.com/user-attachments/assets/4b763196-583a-4531-8f94-c780f79fb7df" />
<img width="612" height="572" alt="image" src="https://github.com/user-attachments/assets/f7f8a768-7f77-47ee-99b8-3b2a251c651b" />
<img width="612" height="572" alt="image" src="https://github.com/user-attachments/assets/38743067-ce26-45f7-b292-4e7d7ece4267" />

## Features

- **Drag & Drop**: Simply drag any video file onto the app window
- **Click to Browse**: Or use the file picker to select videos
- **High-Quality Output**: Uses FFmpeg with optimized palette generation for smooth GIFs
- **Configurable Frame Rate**: Choose relative (0.25×–2×) or fixed (10–60 fps) output frame rate
- **Configurable Resolution**: Choose relative (0.25×–2×) or fixed width (320–1920px)
- **Smart File Naming**: Automatically handles filename collisions (video.gif, video (1).gif, etc.)
- **Flexible Save Location**: Save GIFs next to the original video or to a custom folder
- **Recent Locations**: Quick access to recently used output folders
- **Progress Tracking**: Real-time progress bar during conversion
- **Status Bar**: Quick access to output location, FPS, resolution, and debug mode
- **Debug Mode**: View FFmpeg output in real-time for troubleshooting
- **Native macOS Experience**: Follows system appearance and conventions

## Supported Formats

**Input:** MOV, MP4, M4V, AVI, MKV, WMV, FLV, WebM, MPEG, and more

**Output:** GIF with Lanczos scaling and two-pass palette optimization

## Installation

### Option 1: Download Release

1. Download the latest release from the [Releases page](https://github.com/slavikme/video-to-gif/releases)
2. Drag `Video to GIF.app` to your Applications folder
3. Right-click and select "Open" (required for first launch on unsigned apps)

### Option 2: Build from Source

1. Clone this repository
2. Open `VideoToGIF.xcodeproj` in Xcode
3. Build and run (⌘R)

## Usage

1. **Launch the app**
2. **Drag a video** onto the drop zone (or click to browse)
3. **Wait for conversion** — progress bar shows completion status
4. **Done!** Click "Show in Finder" or "Preview" to access your GIF

### Status Bar

The status bar at the bottom of the window provides quick access to:

| Setting        | Options                                                  |
| -------------- | -------------------------------------------------------- |
| **Location**   | Same folder as video, custom folder, or recent locations |
| **FPS**        | Relative (0.25×–2×) or fixed (10–60 fps)                 |
| **Resolution** | Relative (0.25×–2×) or fixed width (320–1920px)          |
| **Debug**      | Toggle FFmpeg debug output                               |

### Default Settings

- **Frame Rate**: 0.5× (half of original) — balances quality and file size
- **Resolution**: 1× (same as original)
- **Output Location**: Same folder as source video

### Debug Mode

Enable via the Debug menu (⇧⌘D) or click the bug icon in the status bar to see real-time FFmpeg output. Useful for troubleshooting conversion issues.

## FFmpeg Integration

This app bundles FFmpeg for video processing. The conversion uses the following filter chain:

```
fps={fps},scale={width}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse
```

Where `{fps}` and `{width}` are calculated based on your settings:

- **Frame rate**: Either a fixed value or a multiplier of the original video's FPS
- **Width**: Either a fixed pixel width or a multiplier of the original video's width
- **Height**: Automatically calculated to maintain aspect ratio

This creates high-quality GIFs with:

- Lanczos scaling for sharp quality
- Two-pass palette generation for optimal colors
- Configurable frame rate and resolution

## Keyboard Shortcuts

| Shortcut | Action             |
| -------- | ------------------ |
| ⌘,       | Open Settings      |
| ⇧⌘D      | Toggle Debug Mode  |
| ⇧⌘L      | Show FFmpeg Output |

## Development

### Requirements

- macOS 13.0+
- Xcode 15+
- FFmpeg (bundled or system-installed)

### Project Structure

```
VideoToGIF/
├── VideoToGIFApp.swift       # App entry point, menus, About window
├── ContentView.swift         # Main state machine, status bar
├── Views/
│   ├── DropZoneView.swift    # Drag-drop interface
│   ├── ConversionView.swift  # Progress display
│   ├── CompletionView.swift  # Success screen
│   ├── ErrorView.swift       # Error handling
│   ├── SettingsView.swift    # Preferences
│   └── DebugWindowView.swift # FFmpeg output
├── Services/
│   ├── GifConverter.swift    # FFmpeg wrapper
│   ├── FileNaming.swift      # Collision handling
│   └── SettingsManager.swift # UserDefaults persistence
└── Resources/
    └── ffmpeg                # Bundled binary
```

## Author

**Slavik Meltser**

- GitHub: [@slavikme](https://github.com/slavikme)

## License

MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgments

- [FFmpeg](https://ffmpeg.org/) — The powerful multimedia framework that makes this possible
