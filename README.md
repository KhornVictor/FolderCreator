# mkfolders

A simple and lightweight Rust CLI tool for creating multiple folders at once.

Instead of repeatedly using `mkdir`, `mkfolders` lets you create multiple directories with a single command.

The folders are created relative to your **current terminal location**, so you can use the command from any drive or directory.

## Features

* Create multiple folders with one command
* Automatically uses the current working directory
* Supports nested directories
* Works with Windows paths and drives
* Built with Rust
* Lightweight and fast

## Example

If your current directory is:

```text
D:\Khorn
```

Run:

```powershell
mkfolders src components pages services utils
```

The result will be:

```text
D:\Khorn
├── src
├── components
├── pages
├── services
└── utils
```

If you move to another directory:

```powershell
cd C:\Desktop
```

You can run the same command:

```powershell
mkfolders src components pages
```

And the folders will be created in:

```text
C:\Desktop
├── src
├── components
└── pages
```

## Nested Folders

`mkfolders` also supports nested directories.

```powershell
mkfolders src/components/ui src/components/layout src/services/api src/utils
```

This creates:

```text
src/
├── components/
│   ├── ui/
│   └── layout/
├── services/
│   └── api/
└── utils/
```

Parent directories are automatically created when necessary.

## Installation

### 1. Clone the repository

```powershell
git clone https://github.com/KhornVictor/mkfolders.git
cd mkfolders
```

### 2. Build the project

```powershell
cargo build --release
```

The executable will be generated at:

```text
target\release\mkfolders.exe
```

## Add to PowerShell

You can place the executable somewhere permanent, for example:

```text
C:\Tool\mkfolders\mkfolders.exe
```

Then add the following function to your PowerShell profile.

Open your profile:

```powershell
notepad $PROFILE
```

Add:

```powershell
function mkfolders {
    & "C:\Tool\mkfolders\mkfolders.exe" @args
}
```

Save the file and reload your profile:

```powershell
. $PROFILE
```

Now you can use:

```powershell
mkfolders src components services
```

from anywhere.

## How It Works

The program gets the terminal's current working directory using Rust's:

```rust
std::env::current_dir()
```

It then combines that path with each folder name:

```rust
let path = current_path.join(&folder);
```

Finally, it creates the directory using:

```rust
fs::create_dir_all(&path);
```

`create_dir_all()` is used so nested directories can be created automatically.

## Usage

```text
mkfolders <folder1> <folder2> <folder3> ...
```

### Basic

```powershell
mkfolders src
```

### Multiple folders

```powershell
mkfolders src components services utils
```

### Nested folders

```powershell
mkfolders src/components/ui src/services/api public/images
```

## Example Output

```text
Location: D:\Khorn

Created: D:\Khorn\src
Created: D:\Khorn\components
Created: D:\Khorn\services
Created: D:\Khorn\utils
```

## Requirements

* Windows
* Rust
* Cargo
* PowerShell

You can install Rust from the official Rust website:

[Rust](https://www.rust-lang.org/)

## Project Structure

```text
mkfolders/
├── Cargo.toml
├── Cargo.lock
└── src/
    └── main.rs
```

## License

This project is open source and can be used, modified, and distributed freely.
