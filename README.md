# PlayTorrioPlayer

A portable, cross-platform video player based on mpv with a custom purple-themed UI and external subtitle provider support.

## Features

- Modern purple-themed UI (ModernZ OSC)
- Custom subtitle and audio track menus
- External subtitle provider support (load subtitles from URLs)
- Portable - no installation required
- Cross-platform (Windows, macOS, Linux)

## Usage

### Basic playback
```bash
playtp "https://example.com/video.mp4"
```

### With external subtitles
```bash
playtp "video_url" ProviderName "SubtitleName" "SubtitleURL" "SubName2" "SubURL2"
```

### Multiple providers
```bash
playtp "video_url" OpenSubtitles "English" "https://sub1.srt" "Spanish" "https://sub2.srt" Subscene "French" "https://sub3.srt"
```

## Keyboard Shortcuts

- `Space` - Play/Pause
- `Left/Right` - Seek 5 seconds
- `Up/Down` - Volume
- `F` - Fullscreen
- `M` - Mute
- `V` - Toggle subtitles
- `ESC` - Close menu / Exit fullscreen

## Building

The GitHub Actions workflow automatically builds packages for:
- Windows (with bundled mpv)
- macOS (with bundled mpv)
- Linux (uses system mpv)

To create a release, push a tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Manual Setup

1. Download mpv for your platform
2. Place `mpv` (or `mpv.exe`) in the PlayTorrioPlayer folder
3. Run `playtp` (or `playtp.cmd` on Windows)

## License

MIT
