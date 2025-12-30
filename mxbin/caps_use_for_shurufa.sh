#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then 
  echo "请使用 sudo 运行此脚本"
  exit
fi

# 1. 检查并安装 keyd
if ! command -v keyd &> /dev/null; then
    echo "未检测到 keyd，正在安装..."
    pacman -Syu --noconfirm keyd
else
    echo "keyd 已经安装，跳过安装步骤。"
fi

# 2. 创建配置目录
mkdir -p /etc/keyd

# 3. 写入配置文件 (Caps Lock 映射为 F13)
echo "正在配置 keyd (Caps Lock -> F13)..."
cat <<EOF > /etc/keyd/default.conf
[ids]
*

[main]
# 禁用大小写功能，映射为 F13 用于切换输入法
capslock = f13
EOF

# 4. 设置服务自启动并立即启动
echo "正在启动 keyd 服务..."
systemctl enable keyd
systemctl restart keyd

echo "------------------------------------------------"
echo "完成！现在 Caps Lock 键已识别为 F13。"
echo "请前往你的输入法设置（如 Fcitx5），将切换键绑定为 Caps Lock 即可。"
