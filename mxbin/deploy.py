#!/usr/bin/env python3

import os
import os.path as op
import shutil


def deploy_seed_files(dotfile_dir):
    seed_mapping = {
        "noctalia/settings.example.toml": op.expanduser(
            "~/.local/state/noctalia/settings.toml"
        ),
    }

    for src_name, tgt_path in seed_mapping.items():
        src_path = op.join(dotfile_dir, src_name)
        if not op.isfile(src_path):
            print(f"⚠️  种子文件不存在: {src_path}")
            continue

        if op.lexists(tgt_path):
            if not op.islink(tgt_path) or op.exists(tgt_path):
                continue
            os.unlink(tgt_path)

        os.makedirs(op.dirname(tgt_path), exist_ok=True)
        shutil.copy2(src_path, tgt_path)
        print(f"📄 状态初始化: {tgt_path} ← {src_path}")


def deploy_dotfiles():
    DOTFILE_DIR = op.expanduser("~/.dotfiles")
    MAPPING = {
        "hypr": op.expanduser("~/.config/hypr"),
        "flameshot": op.expanduser("~/.config/flameshot"),
        "fuzzel": op.expanduser("~/.config/fuzzel"),
        "nvim": op.expanduser("~/.config/nvim"),
        "rofi": op.expanduser("~/.config/rofi"),
        # "waybar": op.expanduser("~/.config/waybar"),
        "yazi": op.expanduser("~/.config/yazi"),
        "kitty": op.expanduser("~/.config/kitty"),
        "mpv": op.expanduser("~/.config/mpv"),
        "mxbin": op.expanduser("~/.mxbin"),
        # 垫片：会话 PATH 里 ~/.local/bin 在 /usr/bin 之前，用它接管 Hyprland 启动
        "mxbin/hyprland": op.expanduser("~/.local/bin/Hyprland"),
        "starship": op.expanduser("~/.config/starship"),
        "zsh/zshrc": op.expanduser("~/.zshrc"),
        "zsh/config": op.expanduser("~/.config/zsh"),
        "jj/config.toml": op.expanduser("~/.config/jj/config.toml"),
        "latex/latexmkrc": op.expanduser("~/.latexmkrc"),
        "zed": op.expanduser("~/.config/zed"),
        "cava": op.expanduser("~/.config/cava"),
        "noctalia/config.toml": op.expanduser("~/.config/noctalia/config.toml"),
        "noctalia/templates": op.expanduser("~/.config/noctalia/templates"),
        "patch/qq-flags.conf": op.expanduser("~/.config/qq-flags.conf"),
        "systemd/user": op.expanduser("~/.config/systemd/user"),
        "patch/applications": op.expanduser("~/.local/share/applications"),
    }

    for src_name, tgt_path in MAPPING.items():
        src_path = op.join(DOTFILE_DIR, src_name)

        if not op.exists(src_path):
            print(f"⚠️  源文件不存在: {src_path}")
            continue

        # 处理文件类型配置
        if op.isfile(src_path):
            os.makedirs(op.dirname(tgt_path), exist_ok=True)
            if op.exists(tgt_path):
                if op.islink(tgt_path):
                    current_src = os.readlink(tgt_path)
                    if current_src == src_path:
                        continue  # 链接已正确
                    os.unlink(tgt_path)  # 删除旧链接
                    os.symlink(src_path, tgt_path)
                    print(f"🔗 链接更新: {tgt_path} → {src_path}")
                else:
                    print(f"⛔ 非链接文件已存在: {tgt_path}")
            else:
                os.symlink(src_path, tgt_path)
                print(f"🔗 链接创建: {tgt_path} → {src_path}")

        # 处理目录类型配置
        elif op.isdir(src_path):
            for root, _, files in os.walk(src_path):
                for file in files:
                    src_file = op.join(root, file)
                    rel_path = op.relpath(src_file, src_path)
                    tgt_file = op.join(tgt_path, rel_path)

                    os.makedirs(op.dirname(tgt_file), exist_ok=True)

                    if op.exists(tgt_file):
                        if op.islink(tgt_file):
                            current_target = os.readlink(tgt_file)
                            if current_target == src_file:
                                continue  # 链接已正确
                            os.unlink(tgt_file)
                            os.symlink(src_file, tgt_file)
                            print(f"🔗 链接更新: {tgt_file} → {src_file}")
                        else:
                            print(f"⛔ 非链接文件已存在: {tgt_file}")
                            continue
                    else:
                        os.symlink(src_file, tgt_file)
                        print(f"🔗 链接创建: {tgt_file} → {src_file}")

    deploy_seed_files(DOTFILE_DIR)


if __name__ == "__main__":
    deploy_dotfiles()
