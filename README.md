# 📁 FolderCreator (`mkfolders`)

A modern, fast, and interactive CLI tool built in Rust for scaffolding directory structures in seconds.

Instead of typing `mkdir` repeatedly, **FolderCreator** lets you enter folders interactively with a visual tree preview or batch-create them from command-line arguments. Everything defaults to your **current terminal directory**, with zero tedious configuration.

---

## ✨ Features

- **⚡ Streamlined Interactive Mode**: Enter folder names one by one (`Folder #1:`, `Folder #2:`). Typing `q` or pressing Enter on a blank line **immediately auto-creates** the folders.
- **🌳 Visual ASCII Tree Preview**: See the exact directory hierarchy before disk operations begin.
- **📊 Animated Progress & Summary**: Live progress bar with spinners powered by `indicatif`, followed by a color-coded creation summary card.
- **📂 Zero Path Questions**: Automatically targets your current working directory (`env::current_dir()`).
- **🚀 CLI Batch Scriptability**: Run `mkfolders src docs tests` for instant non-interactive creation.
- **🛡️ Path Sanitization**: Automatically normalizes forward/backward slashes and strips illegal Windows filename characters (`< > : " | ? *`).
- **🪟 File Explorer Shortcut**: Option to open the target folder in Windows File Explorer right from the terminal.
- **🧱 Modular Rust Codebase**: Clean separation across `tree`, `creator`, `interactive`, `cli`, and `ui` modules.

---

## 🚀 Quick Start & Installation

### Option 1: One-Liner Install (PowerShell `irm`)

Open PowerShell and paste this single command:

```powershell
irm https://raw.githubusercontent.com/KhornVictor/FolderCreator/main/install.ps1 | iex
```

This will automatically:

1. Download or clone the latest source code.
2. Build the optimized release binary using Cargo.
3. Configure your PowerShell `$PROFILE` with `mkfolders` and `foldercreator`.
4. Add the binary to your User `PATH`.
5. Load it into your current terminal immediately.

---

### Option 2: Local Automated Install

If you have already cloned the repository:

```powershell
# Inside C:\Tool\FolderCreator
.\install.ps1
```

---

### Option 3: Manual Installation

#### 1. Build the Release Binary

```shell
cargo build --release
```

The executable will be located at:

```text
C:\Tool\FolderCreator\target\release\FolderCreator.exe
```

#### 2. Add to PowerShell Profile

Open your PowerShell profile:

```shell
notepad $PROFILE
```

Add this snippet to the file:

```shell
function mkfolders {
    & "C:\Tool\FolderCreator\target\release\FolderCreator.exe" @args
}
Set-Alias -Name foldercreator -Value mkfolders -ErrorAction SilentlyContinue
```

Reload your profile:

```shell
. $PROFILE
```

---

## 💻 Usage

### 1. Interactive Mode

Run `mkfolders` with no arguments:

```shell
mkfolders
```

#### Interactive Walkthrough

```text
╔═════════════════════════════════════════════════════════════╗
║                    📁 FOLDER CREATOR                        ║
║          Fast, modern & interactive directory builder       ║
╚═════════════════════════════════════════════════════════════╝

⚡ Interactive Mode
📂 Target directory: C:\Projects\MyApp
Enter folder names one by one (type 'q' or press Enter to auto-create):

Folder #1: src/controllers
  ✓ Added 'src/controllers' (Total: 1)
Folder #2: src/models
  ✓ Added 'src/models' (Total: 2)
Folder #3: docs/api
  ✓ Added 'docs/api' (Total: 3)
Folder #4: q

┌─────────────────────────────────────────────────────────────┐
│                    STRUCTURE PREVIEW                        │
└─────────────────────────────────────────────────────────────┘
📂 Base: C:\Projects\MyApp

├── 📁 docs
│   └── 📁 api
└── 📁 src
    ├── 📁 controllers
    └── 📁 models

📊 Total folders to create: 3

🚀 Creating folders...
[██████████████████████████████] 3/3 Processing docs/api

╔═════════════════════════════════════════════════════════════╗
║                      CREATION SUMMARY                       ║
╚═════════════════════════════════════════════════════════════╝
  📂 Target Directory: C:\Projects\MyApp
  ✨ Newly Created:    3
  ℹ  Already Existed:  0
  ✖  Failed:           0

  Created Folders:
    ✓ docs/api
    ✓ src/controllers
    ✓ src/models

? Open target folder in Windows File Explorer? (y/N)
```

---

### 2. Command-Line Arguments Mode

You can also pass folders directly as arguments:

```powershell
mkfolders src components pages services utils
```

#### Nested Folders

Deep paths are created automatically:

```shell
mkfolders src/components/ui src/services/api docs/architecture
```

#### Help Flag

```shell
mkfolders --help
```

---

## 📁 Project Architecture

The codebase is organized into modular Rust files:

```text
FolderCreator/
├── Cargo.toml          # Project dependencies (inquire, colored, indicatif)
├── install.ps1         # Automated Windows PowerShell installer
├── profile.ps1         # Shell function & alias loader for $PROFILE
├── README.md           # Documentation
└── src/
    ├── main.rs         # Application entry point & CLI vs Interactive router
    ├── interactive.rs  # Interactive prompt loop (auto-creates on 'q')
    ├── cli.rs          # Command-line argument handling & help output
    ├── creator.rs      # Folder sanitization, creation loop & summary stats
    ├── tree.rs         # Hierarchical tree builder & ASCII tree renderer
    └── ui.rs           # Terminal banners, summary card & Explorer integration
```

---

## 🔧 Requirements

- **OS**: Windows 10/11
- **Rust & Cargo**: [rustup.rs](https://rustup.rs) (Rust 1.70+)
- **PowerShell**: Windows PowerShell 5.1 or PowerShell 7+

---

## 🗑️ Uninstallation

If you ever wish to remove the tool:

1. Open your profile with `notepad $PROFILE` and remove the `FolderCreator` / `mkfolders` block.
2. Delete the `C:\Tool\FolderCreator` directory.
