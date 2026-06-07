# Dotfiles

My personal dotfiles for Hyprland-based Wayland environment.

## 📦 Main Components

- **Window Manager**: [Hyprland](https://github.com/hyprwm/Hyprland) - Dynamic tiling Wayland compositor
- **Terminal**: [Kitty](https://github.com/kovidgoyal/kitty) - Fast, feature-rich GPU-accelerated terminal
- **Shell**: [Zsh](https://www.zsh.org/) + [Starship](https://starship.rs/) - Powerful shell with custom prompt
- **Editor**: [Neovim](https://github.com/neovim/neovim) + [Zed](https://zed.dev/) - Modern editors for different needs
- **Launcher**: [Rofi](https://github.com/davatorium/rofi) - Application launcher and window switcher
- **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) - Customizable Wayland status bar
- **Notifications**: [Dunst](https://github.com/dunst-project/dunst) - Lightweight notification daemon
- **File Manager**: [Yazi](https://github.com/sxyazi/yazi) - Blazing fast terminal file manager
- **Version Control**: [Jujutsu](https://github.com/martinvonz/jj) - Git-compatible VCS
- **Shell Scripting**: [Ashell](https://github.com/xxchan/ashell) - POSIX-compliant shell scripting library

## 🚀 Installation

```bash
# Clone the repository
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# Run the deployment script
uv run mxbin/deploy.py
```

The deployment script will create symlinks from `~/.dotfiles` to the appropriate locations in your home directory.

## 📁 Project Structure

```
.
├── ashell/          # Ashell shell scripting configuration
├── dunst/           # Notification daemon config
├── hypr/            # Hyprland configs (main, plugins, launcher, lock)
├── jj/              # Jujutsu version control config
├── kitty/           # Kitty terminal emulator config
├── latexmkrc        # LaTeX compilation settings
├── mxbin/           # Custom shell scripts
├── nvim/            # Neovim configuration
├── rofi/            # Rofi launcher themes and configs
├── starship/        # Starship prompt configuration
├── waybar/          # Waybar status bar config
├── yazi/            # Yazi file manager config
├── zed/             # Zed editor settings
└── zsh/             # Zsh shell configuration
```

## 🛠️ Custom Scripts (mxbin)

- `deploy.py` - Symlink deployment script
- `screenShot.sh` - Screenshot tool
- `clipboard.sh` - Clipboard manager
- `gamemode.sh` - Game mode toggle
- `swytch.sh` - Window/workspace switcher
- `waybarCava.sh` - Audio visualizer for Waybar
- `caps_use_for_shurufa.sh` - Caps Lock remapping for input methods
- `chwp` - Wallpaper changer
- `jy` - Utility script

## ⚙️ Configuration Details

### Hyprland
- Located in `hypr/`
- Contains main config, plugins, launcher, and lock screen settings
- Sub-configs for bindings, colors, executables, and window rules

### Neovim
- LazyVim-based configuration
- Located in `nvim/`
- See `nvim/README.md` for editor-specific details

### Kitty
- Multiple theme support (current, dank)
- Located in `kitty/`

### Waybar
- Custom styled status bar with modules
- Located in `waybar/`

## 📝 Notes

- Configuration files are managed via symbolic links
- Existing files will not be overwritten (check deployment script output)
- Tested on Arch Linux with Wayland session

## 📄 License

[MIT](./LICENSE)
