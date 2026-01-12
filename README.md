# Video to GIF

A native macOS app that converts videos to high-quality GIFs using FFmpeg. Built with SwiftUI.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Drag & Drop**: Simply drag any video file onto the app window
- **Click to Browse**: Or use the file picker to select videos
- **High-Quality Output**: Uses FFmpeg with optimized palette generation for smooth GIFs
- **Smart File Naming**: Automatically handles filename collisions (video.gif, video (1).gif, etc.)
- **Flexible Save Location**: Save GIFs next to the original video or to a custom folder
- **Progress Tracking**: Real-time progress bar during conversion
- **Debug Mode**: View FFmpeg output in real-time for troubleshooting
- **Native macOS Experience**: Follows system appearance and conventions

## Supported Formats

Input: MOV, MP4, M4V, AVI, MKV, WMV, FLV, WebM, MPEG, and more

Output: GIF (same resolution, half frame rate for optimal file size, with palette optimization)

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
3. **Wait for conversion** - progress bar shows completion status
4. **Done!** Click "Show in Finder" or "Preview" to access your GIF

### Settings (⌘,)

- **Output Location**: Save GIFs in the same folder as the source video, or choose a custom location

### Debug Mode

Enable via the Debug menu to see real-time FFmpeg output. Useful for troubleshooting conversion issues.

## FFmpeg Integration

This app bundles FFmpeg for video processing. The conversion uses the following filter chain:
```
fps=25,scale=996:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse
```

This creates high-quality GIFs with:
- Half the frame rate of the original video (reduces file size significantly)
- Same resolution as the original video
- Lanczos scaling for sharp quality
- Two-pass palette generation for optimal colors

## Development

### Requirements
- macOS 13.0+
- Xcode 15+
- FFmpeg (bundled or system-installed)

### Project Structure
```
VideoToGIF/
├── VideoToGIFApp.swift       # App entry point, menus
├── ContentView.swift         # Main state machine
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
│   └── SettingsManager.swift # UserDefaults
└── Resources/
    └── ffmpeg                # Bundled binary
```

## Author

**Slavik Meltser**
- GitHub: [@slavikme](https://github.com/slavikme)

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [FFmpeg](https://ffmpeg.org/) - The powerful multimedia framework that makes this possible

