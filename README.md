# Dotfiles（个人配置文件）

基于 Hyprland 的 Wayland 桌面环境（Arch Linux）的个人配置文件仓库。
配置由本仓库统一管理（版本控制使用 [Jujutsu](https://github.com/martinvonz/jj)），
并通过 `mxbin/deploy.py` 以符号链接的方式部署到主目录对应位置。

> 本文件（README.md）为中文标准版；英文翻译见 [README.en.md](./README.en.md)。

## 概览

- **桌面环境（极简三件套）**：Hyprland（窗口管理器）、Rofi（启动器）、Noctalia（bar,壁纸,锁屏等等）
- **文本编辑**：Neovim（LazyVim）、Zed
- **终端与 Shell**：Kitty、Zsh、Starship
- **媒体播放**：mpv
- **输入法**：fcitx5 + Rime
- **版本控制**：Jujutsu
- **其他工具**：Yazi（文件管理器）、Flameshot（截图）、Cava（音频可视化）

## 安装

```bash
# 克隆仓库
git clone <你的仓库地址> ~/.dotfiles
cd ~/.dotfiles

# 部署（在主目录里创建符号链接）
uv run mxbin/deploy.py
```

`deploy.py` 不会覆盖已存在的非符号链接文件；遇到这种情况会打印警告并跳过。

## 目录指南

配置目录按用途分类。“部署到”一列说明 `deploy.py` 会把仓库内容以符号链接
放到主目录的哪个位置。

### 桌面环境

| 路径 | 部署到 | 用途 |
|---|---|---|
| `hypr/` | `~/.config/hypr` | Hyprland 配置：`hyprland.lua` 主配置、`configs/` 下的 Lua 模块与 `plugins/` 插件配置 |
| `rofi/` | `~/.config/rofi` | Rofi 启动器主题与配置 |
| `noctalia/` | `~/.config/noctalia/config.toml` | Noctalia 壁纸/顶栏辅助配置 |

### 文本编辑

| 路径 | 部署到 | 用途 |
|---|---|---|
| `nvim/` | `~/.config/nvim` | Neovim 配置（LazyVim）；详见 `nvim/README.md` |
| `zed/` | `~/.config/zed` | Zed 编辑器设置 |

### 终端与 Shell

| 路径 | 部署到 | 用途 |
|---|---|---|
| `kitty/` | `~/.config/kitty` | Kitty 终端配置与主题 |
| `zsh/` | `~/.zshrc` + `~/.config/zsh` | Zsh 配置文件与模块 |
| `starship/` | `~/.config/starship` | Starship 提示符配置 |

### 媒体播放

| 路径 | 部署到 | 用途 |
|---|---|---|
| `mpv/` | `~/.config/mpv` | mpv 播放器配置 |

### 输入法（fcitx5 + Rime）

没有专属配置目录：Rime 基础配置来自系统（`/usr/share/rime-data`），用户数据
放在 `~/.local/share/fcitx5/rime`。本仓库贡献的是剪贴板学习脚本及其 timer，
见下文 [Rime 输入法](#rime-输入法)。

### 其他工具

| 路径 | 部署到 | 用途 |
|---|---|---|
| `yazi/` | `~/.config/yazi` | Yazi 文件管理器配置 |
| `flameshot/` | `~/.config/flameshot` | Flameshot 截图工具设置 |
| `cava/` | `~/.config/cava` | Cava 音频可视化配置 |

### 仓库自动化与元配置

| 路径 | 部署到 | 用途 |
|---|---|---|
| `mxbin/` | `~/.mxbin` | 自用脚本与工具（deploy.py、rime-clipboard-learn.py 等） |
| `systemd/` | `~/.config/systemd/user` | systemd 用户单元（见下文「systemd 用户单元」） |
| `patch/` | `~/.config/qq-flags.conf` + `~/.local/share/applications` | 程序补丁：启动参数与 `.desktop` 覆盖（见下） |
| `skills/` | 由 `mxbin/deploy-skills` 安装 | Codex 技能包（jujutsu-first、obsidian、system-security-health） |
| `jj/` | `~/.config/jj/config.toml` | Jujutsu 版本控制配置 |
| `latex/` | `~/.latexmkrc` | LaTeX 编译设置（latexmk） |

### `patch/` —— 程序补丁

`patch/` 存放对第三方程序的小型覆盖，而不是它们的完整配置树：

- `qq-flags.conf` 为 Linux QQ 追加命令行参数。注意：该文件只被 Arch AUR
  `linuxqq` 包的启动包装脚本读取（`/usr/bin/linuxqq`，即 PKGBUILD 中的
  `linuxqq.sh`）；官方 .deb/.rpm 包及其他 AUR 变体不一定支持，详情见文件头部注释。
- `applications/*.desktop` 是用户级 `.desktop` 补丁，部署到
  `~/.local/share/applications`，用于出现在应用菜单中。

### `_deprecated/` —— 弃用配置存档

不再使用的配置放在这里留作参考而不是直接删除：通知守护进程 `dunst`、
状态栏 `waybar`、旧的 Hyprland 配置结构、`ashell` shell 脚本库配置、
`mako` 通知守护进程配置，以及 hypridle/hyprlock/hyprlauncher 三个组件
（锁屏/待机/启动器功能已由 Noctalia 提供）。它们刻意**不**在 `deploy.py` 里。

## 自用脚本（mxbin）

以下为常用脚本；完整清单见 `mxbin/` 目录：

- `deploy.py` —— 符号链接部署脚本（见上文）
- `deploy-skills` —— 安装 `skills/` 技能包
- `rime-clipboard-learn.py` —— 把高频复制词提升到 Rime 用户词典（见下文）
- `screenShot.sh`、`flameshot-gui`、`flameshot-full`、`clipimg`、`clipboard.sh` ——
  截图与剪贴板辅助
- `chwp`、`noctalia-wallpaper-sync` —— 壁纸工具
- `hyprsunsetctl`、`log-health` —— Hyprland 会话辅助与诊断
- `caps_use_for_shurufa.sh` —— 输入法用的 Caps Lock 改键

## systemd 用户单元

`systemd/user/` 下的单元由 deploy.py 以符号链接部署到
`~/.config/systemd/user`，配合 `mxbin/` 中的脚本工作：

| 单元 | 类型 | 作用 |
|---|---|---|
| `rime-clipboard-learn.timer` | timer | 开机 15 分钟后运行一次，之后每 30 分钟一次；`Persistent=true` 保证错过的触发会在下次开机补跑 |
| `rime-clipboard-learn.service` | oneshot | 先 `--scan` 扫描 cliphist 历史，再 `--import` 把高频复制词导入 Rime 用户词典（见下文「Rime 输入法」） |
| `wallpaper-link-sync.path` | path | 监听 Noctalia 状态文件（`~/.local/state/noctalia/settings.toml`、`wallpaper_shuffle.json`）的变化 |
| `wallpaper-link-sync.service` | oneshot | 状态变化时运行 `noctalia-wallpaper-sync`，把 Hyprland 的 `wallpaper.link` 指向 Noctalia 当前壁纸 |

启用方式：

```bash
systemctl --user enable --now rime-clipboard-learn.timer
systemctl --user enable --now wallpaper-link-sync.path
```

## Rime 输入法

基础配置位于系统目录（`/usr/share/rime-data`，默认朙月拼音），用户数据在
`~/.local/share/fcitx5/rime`。Rime 会从你的输入中学习（用户词典），但对“复制”
的内容一无所知。两种让它更聪明的方式：

1. **手动固定短语** —— 创建 `~/.local/share/fcitx5/rime/custom_phrase.txt`，
   每行格式为 `文字<Tab>编码<Tab>权重`（权重可省略，越大越靠前），然后重新部署
   （输入法托盘菜单“重新部署”，或 `fcitx5-remote -r`）。
2. **剪贴板学习** —— `rime-clipboard-learn.py` 扫描 cliphist 历史、统计高频词，
   以提升权重的方式导入 `luna_pinyin.userdb`。启用方式：

   ```bash
   uv run mxbin/deploy.py          # 部署 mxbin/ 与 systemd/user/ 的符号链接
   systemctl --user daemon-reload
   systemctl --user enable --now rime-clipboard-learn.timer
   ```

   timer 每 30 分钟扫描一次；登录时 Hyprland autostart 会在 fcitx5 启动前应用
   待导入的词，因此不会打断输入。可用脚本头部注释中的环境变量调节行为
   （`RIME_LEARN_THRESHOLD`、`RIME_LEARN_STATE_DIR` 等）。

## 配置细节

### Hyprland

- 位于 `hypr/`
- 主配置由 Lua 驱动（`hyprland.lua` + `configs/*.lua`），覆盖 autostart、按键、
  显示器、窗口规则、工作区与手势
- autostart 包含 fcitx5、cliphist 监听，以及让 Linux QQ 在原生 Wayland 下
  剪贴板可用的 `xwayclip` 桥接

### Neovim

- 基于 LazyVim 的配置，位于 `nvim/`
- 编辑器细节见 `nvim/README.md`

### Kitty

- 多主题支持（current、dank），位于 `kitty/`

## 说明

- 配置文件通过符号链接管理
- 不会覆盖已有文件（注意查看部署脚本输出）
- 在 Arch Linux + Wayland 会话下测试

## 许可证

[MIT](./LICENSE)
