# BetterScreenshareAudio

A BetterDiscord plugin that enhances screenshare audio on Linux by allowing you to choose specific audio sources for your screenshare.

## ✨ Features

- **Selective Audio Sources**: Choose exactly which audio sources to include in your screenshare
- **Multiple Source Support**: Include multiple audio sources simultaneously
- **Discord Audio Control**: Option to include or exclude Discord's own audio
- **System Audio**: Include entire system audio or specific applications
- **Easy Interface**: Integrated directly into Discord's Go Live modal
- **Fallback Support**: Option to use Discord's built-in soundshare as fallback

## 🚀 Quick Installation

Use the automated installer script for the easiest setup:

```bash
git clone https://github.com/F1r3d3v/BetterScreenshareAudio.git
./install.sh
```

The installer will:
1. Check for required dependencies (pnpm)
2. Clone and build BetterDiscord
3. Let you choose your Discord version (Stable/Canary/PTB)
4. Install BetterDiscord
5. Copy the plugin to the correct location

## 📋 Manual Installation

### Prerequisites

1. **BetterDiscord Fork**: This plugin requires a special fork of BetterDiscord that includes venmic support

2. **Linux System**: This plugin is specifically designed for Linux systems with PipeWire/PulseAudio

### Manual Steps

1. **Install the BetterDiscord Fork**:
   ```bash
   git clone https://github.com/F1r3d3v/BetterDiscord
   cd BetterDiscord
   pnpm install
   pnpm run install-stable  # or install-canary, install-ptb
   ```

2. **Download and Install Plugin**:
   - Download `BetterScreenshareAudio.plugin.js`
   - Place it in your BetterDiscord plugins folder:
     - `~/.config/BetterDiscord/plugins/`

3. **Enable the Plugin**:
   - Open Discord
   - Go to Settings → BetterDiscord → Plugins
   - Enable "BetterScreenshareAudio"

## 🎮 Usage

1. **Start a Screenshare**: Click the screenshare button in a voice channel
2. **Configure Audio**: In the Go Live modal, you'll see an "Audio Source" dropdown
3. **Select Sources**: 
   - **Entire system**: Shares all system audio
   - **Discord**: Includes Discord's audio in the share
   - **Specific Applications**: Choose individual applications by name
   - **Media Sources**: Select specific audio streams
4. **Options**: 
   - Toggle "Use Discord's Soundshare" to fall back to built-in behavior
5. **Start Stream**: Click "Go Live" to start streaming with your selected audio

## ⚙️ Audio Source Options

- **Entire system**: Captures all system audio
- **Discord**: Includes Discord's own audio (useful for playback, etc.)
- **Application-specific**: Select audio from specific running applications
- **Media streams**: Choose individual audio streams with more granular control

## 🔧 Configuration

The plugin stores settings in BetterDiscord's data folder. Current settings include:

- `useBuildInSoundshare`: Whether to use Discord's built-in soundshare instead of venmic

## 🙏 Acknowledgments

This project builds upon the excellent work of several open-source projects:

### [venmic](https://github.com/Vencord/venmic)
**Huge thanks to the Vencord team for venmic!** This project is the backbone that makes selective audio sharing possible on Linux. venmic provides the low-level PipeWire integration that allows us to create virtual microphones and route specific audio sources. Without venmic, this plugin simply wouldn't exist.

- **Repository**: https://github.com/Vencord/venmic
- **What it does**: Provides Linux audio routing and virtual microphone capabilities
- **Why it's essential**: Enables the core functionality of selective audio source sharing

> [!NOTE]
> This project uses a custom fork of venmic ([F1r3d3v/venmic](https://github.com/F1r3d3v/venmic)) to ensure the necessary audio nodes are linked correctly for optimal compatibility with the plugin's audio source selection features.

### [BetterDiscord](https://github.com/BetterDiscord/BetterDiscord)
**Special appreciation to the BetterDiscord project** for creating the extensibility platform that makes Discord customization possible. BetterDiscord provides the plugin system and API that allows us to modify Discord's interface and behavior.

- **Repository**: https://github.com/BetterDiscord/BetterDiscord
- **What it does**: Provides Discord modification and plugin capabilities
- **Why it's important**: Makes it possible to extend Discord with custom functionality

> [!NOTE]
> This plugin requires a special fork of BetterDiscord ([F1r3d3v/BetterDiscord](https://github.com/F1r3d3v/BetterDiscord)) that includes venmic integration.

## 📝 License

This project is open source. Please refer to the individual projects (venmic and BetterDiscord) for their respective licenses.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## ⚠️ Disclaimer

This plugin modifies Discord's behavior and requires a modified version of BetterDiscord. Use at your own discretion and in accordance with Discord's Terms of Service.
