# Dotfiles

> English translation of [README.md](./README.md), which is the canonical
> (Chinese) version.

Personal dotfiles for a Hyprland-based Wayland environment on Arch Linux.
Configuration is managed in this repository (with [Jujutsu](https://github.com/martinvonz/jj))
and symlinked into place by `mxbin/deploy.py`.

## Overview

The desktop itself is intentionally small — three pieces for the environment,
and everything else is just normal application config:

- **Desktop environment (minimal)**: Hyprland (window manager), Rofi (launcher),
  Noctalia (bar, wallpaper, lockscreen, etc.)
- **Text editing**: Neovim (LazyVim), Zed
- **Terminal & shell**: Kitty, Zsh, Starship
- **Media**: mpv
- **Input method**: fcitx5 + Rime
- **Version control**: Jujutsu
- **Other tools**: Yazi (file manager), Flameshot (screenshot), Cava (audio
  visualizer)

## Installation

```bash
# Clone the repository
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# Deploy (creates symlinks into your home directory)
uv run mxbin/deploy.py
```

`deploy.py` never overwrites an existing non-symlink file; it prints a warning
and skips those entries instead.

## Directory guide

Config directories, grouped by what they configure. “Deployed to” is where
`deploy.py` symlinks them into your home directory.

### Desktop environment

| Path | Deployed to | Purpose |
|---|---|---|
| `hypr/` | `~/.config/hypr` | Hyprland config: `hyprland.lua`, Lua modules in `configs/`, and plugin configs in `plugins/` |
| `rofi/` | `~/.config/rofi` | Rofi launcher themes and config |
| `noctalia/` | `~/.config/noctalia/config.toml` | Noctalia wallpaper/bar helper config |

### Text editing

| Path | Deployed to | Purpose |
|---|---|---|
| `nvim/` | `~/.config/nvim` | Neovim configuration (LazyVim-based); see `nvim/README.md` |
| `zed/` | `~/.config/zed` | Zed editor settings |

### Terminal & shell

| Path | Deployed to | Purpose |
|---|---|---|
| `kitty/` | `~/.config/kitty` | Kitty terminal config and themes |
| `zsh/` | `~/.zshrc` + `~/.config/zsh` | Zsh rc file and module config |
| `starship/` | `~/.config/starship` | Starship prompt configuration |

### Media

| Path | Deployed to | Purpose |
|---|---|---|
| `mpv/` | `~/.config/mpv` | mpv media player config |

### Input method (fcitx5 + Rime)

No dedicated config directory here: the Rime base config comes from the system
(`/usr/share/rime-data`) and user data lives in `~/.local/share/fcitx5/rime`.
This repo contributes the clipboard-learning script and its timer — see
[Rime input method](#rime-input-method) below.

### Other tools

| Path | Deployed to | Purpose |
|---|---|---|
| `yazi/` | `~/.config/yazi` | Yazi file manager config |
| `flameshot/` | `~/.config/flameshot` | Flameshot screenshot tool settings |
| `cava/` | `~/.config/cava` | Cava audio visualizer config |

### Repository automation & meta

| Path | Deployed to | Purpose |
|---|---|---|
| `mxbin/` | `~/.mxbin` | Personal scripts and tools (deploy.py, rime-clipboard-learn.py, …) |
| `systemd/` | `~/.config/systemd/user` | systemd user units (see “systemd user units” below) |
| `patch/` | `~/.config/qq-flags.conf` + `~/.local/share/applications` | Program patches: launch flags and `.desktop` overrides (see below) |
| `skills/` | installed via `mxbin/deploy-skills` | Codex/agent skill packages (jujutsu-first, obsidian, system-security-health) |
| `jj/` | `~/.config/jj/config.toml` | Jujutsu version-control config |
| `latex/` | `~/.latexmkrc` | LaTeX build settings (latexmk) |

### `patch/` — program patches

`patch/` collects small overrides that tweak how third-party programs run,
instead of holding their full config trees:

- `qq-flags.conf` adds command-line flags to Linux QQ. Note: this file is only
  read by the Arch AUR `linuxqq` launcher wrapper (`/usr/bin/linuxqq`, shipped
  as `linuxqq.sh` in the PKGBUILD); official .deb/.rpm packages and other AUR
  variants may not honor it. See the header inside the file for details.
- `applications/*.desktop` are user-level `.desktop` patches, deployed to
  `~/.local/share/applications` so they show up in the app menu.

### `_deprecated/` — archived configs

Configs that are no longer used live here for reference instead of being
deleted: notification daemon `dunst`, status bar `waybar`, an older Hyprland
config layout, the `ashell` shell-scripting library config, the `mako`
notification daemon config, and the hypridle/hyprlock/hyprlauncher trio
(screen lock / idle / launcher are now provided by Noctalia). They are
intentionally **not** in `deploy.py`.

## Custom scripts (mxbin)

Highlights; the full inventory lives in `mxbin/`:

- `deploy.py` — symlink deployment script (see above)
- `deploy-skills` — installs the `skills/` packages
- `rime-clipboard-learn.py` — boosts frequently copied words in the Rime user
  dictionary (see below)
- `screenShot.sh`, `flameshot-gui`, `flameshot-full`, `clipimg`, `clipboard.sh` —
  screenshot and clipboard helpers
- `chwp`, `noctalia-wallpaper-sync` — wallpaper tooling
- `hyprsunsetctl`, `log-health` — Hyprland session helpers and diagnostics
- `caps_use_for_shurufa.sh` — Caps Lock remapping for input methods

## systemd user units

Units under `systemd/user/` are symlinked to `~/.config/systemd/user` by
`deploy.py` and work together with the scripts in `mxbin/`:

| Unit | Type | Purpose |
|---|---|---|
| `rime-clipboard-learn.timer` | timer | Runs 15 minutes after boot, then every 30 minutes; `Persistent=true` catches up on missed triggers |
| `rime-clipboard-learn.service` | oneshot | Runs `--scan` over cliphist history, then `--import` boosts frequent words in the Rime user dictionary (see “Rime input method” below) |
| `wallpaper-link-sync.path` | path | Watches Noctalia state files (`~/.local/state/noctalia/settings.toml`, `wallpaper_shuffle.json`) for changes |
| `wallpaper-link-sync.service` | oneshot | Runs `noctalia-wallpaper-sync` on change to point Hyprland’s `wallpaper.link` at Noctalia’s current wallpaper |

Enable them with:

```bash
systemctl --user enable --now rime-clipboard-learn.timer
systemctl --user enable --now wallpaper-link-sync.path
```

## Rime input method

The base config lives in the system directory (`/usr/share/rime-data`, default
朙月拼音) and the user data in `~/.local/share/fcitx5/rime`. Rime already
learns from what you type (user dictionary), but it knows nothing about what
you copy. Two ways to make it smarter:

1. **Manual pinned phrases** — create
   `~/.local/share/fcitx5/rime/custom_phrase.txt` with lines
   `文字<Tab>编码<Tab>权重` (weight optional, larger ranks first), then redeploy
   (input method tray menu "重新部署", or `fcitx5-remote -r`).
2. **Clipboard learning** — `rime-clipboard-learn.py` scans cliphist history,
   counts frequent words, and imports them into `luna_pinyin.userdb` with a
   boosted weight. Enable it with:

   ```bash
   uv run mxbin/deploy.py          # symlinks mxbin/ and systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable --now rime-clipboard-learn.timer
   ```

   The timer scans every 30 minutes; on login the Hyprland autostart applies
   any pending words before fcitx5 starts, so imports never interrupt typing.
   Tune behavior via env vars documented in the script header
   (`RIME_LEARN_THRESHOLD`, `RIME_LEARN_STATE_DIR`, ...).

## Configuration details

### Hyprland

- Located in `hypr/`
- Main config is Lua-driven (`hyprland.lua` + `configs/*.lua`), covering
  autostart, binds, monitors, window rules, workspaces, and gestures
- Autostart includes fcitx5, cliphist watchers, and the `xwayclip` bridge that
  makes Linux QQ's clipboard work under native Wayland

### Neovim

- LazyVim-based configuration, located in `nvim/`
- See `nvim/README.md` for editor-specific details

### Kitty

- Multiple theme support (current, dank), located in `kitty/`

## Notes

- Configuration files are managed via symbolic links
- Existing files will not be overwritten (check deployment script output)
- Tested on Arch Linux with a Wayland session

## License

[MIT](./LICENSE)
