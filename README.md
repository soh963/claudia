<div align="center">
  <img src="https://github.com/user-attachments/assets/92fd93ed-e71b-4b94-b270-50684323dd00" alt="Claudia Logo" width="120" height="120">

  <a href="https://claudiacode.com"><h1>Claudia</h1></a>
  
  <p>
    <strong>A powerful GUI app and Toolkit for Claude Code</strong>
  </p>
  <p>
    <strong>Create custom agents, manage interactive Claude Code sessions, run secure background agents, and more.</strong>
  </p>
  
  <p>
    <a href="#features"><img src="https://img.shields.io/badge/Features-✨-blue?style=for-the-badge" alt="Features"></a>
    <a href="#installation"><img src="https://img.shields.io/badge/Install-🚀-green?style=for-the-badge" alt="Installation"></a>
    <a href="#usage"><img src="https://img.shields.io/badge/Usage-📖-purple?style=for-the-badge" alt="Usage"></a>
    <a href="#development"><img src="https://img.shields.io/badge/Develop-🛠️-orange?style=for-the-badge" alt="Development"></a>
    <a href="https://discord.gg/G9g25nj9"><img src="https://img.shields.io/badge/Discord-Join-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord"></a>
  </p>
</div>

![457013521-6133a738-d0cb-4d3e-8746-c6768c82672c](https://github.com/user-attachments/assets/a028de9e-d881-44d8-bae5-7326ab3558b9)

https://github.com/user-attachments/assets/bf0bdf9d-ba91-45af-9ac4-7274f57075cf

> [!TIP]
> **⭐ Star the repo and follow [@getAsterisk](https://x.com/getAsterisk) on X for early access to `asteria-swe-v0`**.

## 🌟 Overview

**Claudia** is a powerful desktop application that transforms how you interact with Claude Code. Built with Tauri 2, it provides a beautiful GUI for managing your Claude Code sessions, creating custom agents, tracking usage, and much more.

Think of Claudia as your command center for Claude Code - bridging the gap between the command-line tool and a visual experience that makes AI-assisted development more intuitive and productive.

## 🚀 What's New (v0.1.0)

### 🎯 Key Features & Improvements

- **🪟 Background Process Execution**: Claude processes now run silently in the background on Windows - no more console windows popping up
- **🎨 Modern UI/UX**: Complete redesign with Tailwind CSS v4 and shadcn/ui components
- **📦 Windows Installers**: Native MSI and NSIS installers for easy distribution
- **🔧 Improved Claude Binary Detection**: Enhanced support for various installation methods (NVM, Homebrew, system paths)
- **📊 Optional Analytics**: PostHog integration is now completely optional and disabled by default
- **🎯 Better Error Handling**: Improved error messages and recovery mechanisms throughout the application

## 📋 Table of Contents

- [🌟 Overview](#-overview)
- [🚀 What's New](#-whats-new-v010)
- [✨ Features](#-features)
  - [🗂️ Project & Session Management](#️-project--session-management)
  - [🤖 CC Agents](#-cc-agents)
  - [📊 Usage Analytics Dashboard](#-usage-analytics-dashboard)
  - [🔌 MCP Server Management](#-mcp-server-management)
  - [⏰ Timeline & Checkpoints](#-timeline--checkpoints)
  - [📝 CLAUDE.md Management](#-claudemd-management)
- [📖 Usage](#-usage)
- [🚀 Installation](#-installation)
- [🔨 Build from Source](#-build-from-source)
- [🛠️ Development](#️-development)
- [🔒 Security](#-security)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## ✨ Features

### 🗂️ **Project & Session Management**
- **Visual Project Browser**: Navigate through all your Claude Code projects in `~/.claude/projects/`
- **Session History**: View and resume past coding sessions with full context
- **Smart Search**: Find projects and sessions quickly with built-in search
- **Session Insights**: See first messages, timestamps, and session metadata at a glance
- **Todo Integration**: Built-in todo management that syncs with Claude Code sessions

### 🤖 **CC Agents**
- **Custom AI Agents**: Create specialized agents with custom system prompts and behaviors
- **Agent Library**: Build a collection of purpose-built agents for different tasks
- **Background Execution**: Run agents in separate processes for non-blocking operations
- **Execution History**: Track all agent runs with detailed logs and performance metrics
- **Model Selection**: Choose between available Claude models for each agent
- **Permission Control**: Configure file read/write and network access per agent

### 📊 **Usage Analytics Dashboard**
- **Cost Tracking**: Monitor your Claude API usage and costs in real-time
- **Token Analytics**: Detailed breakdown by model, project, and time period
- **Visual Charts**: Beautiful charts showing usage trends and patterns
- **Export Data**: Export usage data for accounting and analysis
- **Resource Monitoring**: Track system resource usage during Claude sessions

### 🔌 **MCP Server Management**
- **Server Registry**: Manage Model Context Protocol servers from a central UI
- **Easy Configuration**: Add servers via UI or import from existing configs
- **Connection Testing**: Verify server connectivity before use
- **Claude Desktop Import**: Import server configurations from Claude Desktop
- **Server Status**: Real-time monitoring of MCP server status

### ⏰ **Timeline & Checkpoints**
- **Session Versioning**: Create checkpoints at any point in your coding session
- **Visual Timeline**: Navigate through your session history with a branching timeline
- **Instant Restore**: Jump back to any checkpoint with one click
- **Fork Sessions**: Create new branches from existing checkpoints
- **Diff Viewer**: See exactly what changed between checkpoints

### 📝 **CLAUDE.md Management**
- **Built-in Editor**: Edit CLAUDE.md files directly within the app
- **Live Preview**: See your markdown rendered in real-time
- **Project Scanner**: Find all CLAUDE.md files in your projects
- **Syntax Highlighting**: Full markdown support with syntax highlighting
- **Template System**: Pre-built templates for common project structures

### 🎨 **User Interface**
- **Dark/Light Mode**: Automatic theme switching based on system preferences
- **Responsive Design**: Works seamlessly on different screen sizes
- **Keyboard Shortcuts**: Extensive keyboard navigation support
- **Customizable Layout**: Arrange panels and tabs to your preference
- **Native Performance**: Built with Tauri for optimal performance

## 📖 Usage

### Getting Started

1. **Launch Claudia**: Open the application after installation
2. **Welcome Screen**: Choose between CC Agents or Projects
3. **First Time Setup**: Claudia will automatically detect your `~/.claude` directory
4. **Configure Settings**: Set your preferred model, theme, and other preferences

### Managing Projects

```
Projects → Select Project → View Sessions → Resume or Start New
```

- Click on any project to view its sessions
- Each session shows the first message and timestamp
- Resume sessions directly or start new ones
- Create checkpoints to save your progress

### Creating Agents

```
CC Agents → Create Agent → Configure → Execute
```

1. **Design Your Agent**: Set name, icon, and system prompt
2. **Configure Model**: Choose between available Claude models
3. **Set Permissions**: Configure file read/write and network access
4. **Execute Tasks**: Run your agent on any project

### Tracking Usage

```
Menu → Usage Dashboard → View Analytics
```

- Monitor costs by model, project, and date
- Export data for reports
- View token usage breakdowns
- Track resource consumption

### Working with MCP Servers

```
Menu → MCP Manager → Add Server → Configure
```

- Add servers manually or via JSON
- Import from Claude Desktop configuration
- Test connections before using
- Monitor server status in real-time

## 🚀 Installation

### Windows

#### Option 1: MSI Installer (Recommended)
Download the latest `.msi` installer from the [Releases](https://github.com/getAsterisk/claudia/releases) page and run it.

#### Option 2: NSIS Installer
Download the `.exe` installer for a more customizable installation experience.

### macOS

Download the `.dmg` file from the [Releases](https://github.com/getAsterisk/claudia/releases) page and drag Claudia to your Applications folder.

### Linux

#### AppImage (Universal)
Download the `.AppImage` file, make it executable, and run:
```bash
chmod +x Claudia-*.AppImage
./Claudia-*.AppImage
```

#### Debian/Ubuntu
```bash
sudo dpkg -i claudia_*.deb
```

### Prerequisites

- **Claude Code CLI**: Install from [Claude's official site](https://claude.ai/code)
- **System Requirements**:
  - Windows 10/11, macOS 11+, or Linux (Ubuntu 20.04+)
  - 4GB RAM minimum (8GB recommended)
  - 500MB available storage

## 🔨 Build from Source

### Prerequisites

1. **Rust** (1.70.0 or later)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Bun** (latest version)
   ```bash
   curl -fsSL https://bun.sh/install | bash
   ```

3. **Platform-specific dependencies**:
   
   **Windows**: 
   - Microsoft C++ Build Tools
   - WebView2 (usually pre-installed)
   
   **Linux**:
   ```bash
   sudo apt install libwebkit2gtk-4.1-dev libgtk-3-dev libayatana-appindicator3-dev
   ```
   
   **macOS**:
   ```bash
   xcode-select --install
   ```

### Build Steps

```bash
# Clone the repository
git clone https://github.com/getAsterisk/claudia.git
cd claudia

# Install dependencies
bun install

# Development build with hot reload
bun run tauri dev

# Production build
bun run tauri build
```

The built executables will be in `src-tauri/target/release/bundle/`.

## 🛠️ Development

### Tech Stack

- **Frontend**: React 18 + TypeScript + Vite 6
- **Backend**: Rust with Tauri 2.5
- **UI Framework**: Tailwind CSS v4 + shadcn/ui
- **Database**: SQLite (via rusqlite)
- **Package Manager**: Bun
- **State Management**: React Context + Hooks
- **IPC**: Tauri Commands + Events

### Project Structure

```
claudia/
├── src/                   # React frontend
│   ├── components/        # UI components
│   ├── lib/              # API client & utilities
│   ├── hooks/            # Custom React hooks
│   └── assets/           # Static assets
├── src-tauri/            # Rust backend
│   ├── src/
│   │   ├── commands/     # Tauri command handlers
│   │   ├── checkpoint/   # Timeline management
│   │   ├── process/      # Process management
│   │   └── claude_binary.rs # Claude detection
│   ├── icons/            # Application icons
│   └── tests/            # Rust test suite
└── public/               # Public assets
```

### Development Commands

```bash
# Start development server
bun run tauri dev

# Run frontend only
bun run dev

# Type checking
bun run check

# Build for production
bun run tauri build

# Run Rust tests
cd src-tauri && cargo test

# Format Rust code
cd src-tauri && cargo fmt
```

### Key Components

- **ClaudeCodeSession**: Main session management component
- **CCAgents**: Agent creation and management
- **UsageDashboard**: Analytics and cost tracking
- **MCPManager**: MCP server configuration
- **TimelineView**: Checkpoint visualization
- **FloatingPromptInput**: Command input interface

## 🔒 Security

Claudia prioritizes your privacy and security:

1. **Process Isolation**: Agents run in separate processes with controlled permissions
2. **No Console Windows**: Background processes run silently without exposing terminals
3. **Local Storage**: All data stays on your machine in SQLite databases
4. **No Telemetry**: Analytics are completely optional and disabled by default
5. **Permission Control**: Granular file and network access configuration
6. **Open Source**: Full transparency through open source code

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Areas for Contribution

- 🐛 Bug fixes and improvements
- ✨ New features and enhancements
- 📚 Documentation improvements
- 🎨 UI/UX enhancements
- 🧪 Test coverage
- 🌐 Internationalization
- 🔧 Performance optimizations

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Tauri](https://tauri.app/) - The secure framework for building desktop apps
- UI components from [shadcn/ui](https://ui.shadcn.com/)
- [Claude](https://claude.ai) by Anthropic
- Icons from [Lucide](https://lucide.dev/)

---

<div align="center">
  <p>
    <strong>Made with ❤️ by <a href="https://asterisk.so/">Asterisk</a></strong>
  </p>
  <p>
    <a href="https://github.com/getAsterisk/claudia/issues">Report Bug</a>
    ·
    <a href="https://github.com/getAsterisk/claudia/issues">Request Feature</a>
    ·
    <a href="https://discord.gg/G9g25nj9">Join Discord</a>
  </p>
</div>

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=getAsterisk/claudia&type=Date)](https://www.star-history.com/#getAsterisk/claudia&Date)