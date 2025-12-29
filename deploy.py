#!/usr/bin/env python3

import os
import os.path as op


def deploy_dotfiles():
    DOTFILE_DIR = op.expanduser("~/.dotfiles")
    MAPPING = {
        "dunst": op.expanduser("~/.config/dunst"),
        "hypr": op.expanduser("~/.config/hypr"),
        "nvim": op.expanduser("~/.config/nvim"),
        "rofi": op.expanduser("~/.config/rofi"),
        "waybar": op.expanduser("~/.config/waybar"),
        "yazi": op.expanduser("~/.config/yazi"),
        "kitty": op.expanduser("~/.config/kitty"),
        "starship": op.expanduser("~/.config/starship"),
        "zsh/zshrc": op.expanduser("~/.zshrc"),
        "zsh/p10k": op.expanduser("~/.p10k.zsh"),
        "zsh/config": op.expanduser("~/.config/zsh"),
        "jj/config.toml": op.expanduser("~/.config/jj/config.toml"),
        "latexmkrc": op.expanduser("~/.latexmkrc"),
    }

    for src_name, tgt_path in MAPPING.items():
        src_path = op.join(DOTFILE_DIR, src_name)

        if not op.exists(src_path):
            print(f"⚠️  源文件不存在: {src_path}")
            continue

        # 处理文件类型配置
        if op.isfile(src_path):
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


if __name__ == "__main__":
    deploy_dotfiles()
