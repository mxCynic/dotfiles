#!/bin/bash

# 配置文件映射表
declare -A configs=(
  ["dunst"]="$HOME/.config/dunst"
  ["hypr"]="$HOME/.config/hypr"
  ["nvim"]="$HOME/.config/nvim"
  ["rofi"]="$HOME/.config/rofi"
  ["waybar"]="$HOME/.config/waybar"
  ["yazi"]="$HOME/.config/yazi"
  ["zshrc"]="$HOME/.zshrc"
  ["latexmkrc"]="$HOME/.latexmkrc"
)

# 创建软链接函数
create_link() {
  local source="$1"
  local target="$2"

  # 检查并处理已存在的链接
  if [[ -L "$target" && $(readlink -f "$target") == $(readlink -f "$source") ]]; then
    echo "✓ 链接已存在: $target"
    return 0
  fi

  # 创建父目录（如果是文件链接）
  if [[ ! -d "$target" ]]; then
    mkdir -p "$(dirname "$target")"
  fi

  # 强制创建链接
  if ln -sf "$source" "$target"; then
    echo "✓ 创建链接: $source -> $target"
  else
    echo "✗ 创建失败: $source -> $target" >&2
    return 1
  fi
}

# 处理目录内容
link_directory() {
  local source_dir="$1"
  local target_dir="$2"

  shopt -s dotglob # 包含隐藏文件
  for item in "$source_dir"/*; do
    local item_name=$(basename "$item")
    create_link "$item" "$target_dir/$item_name"
  done
  shopt -u dotglob
}

# 主流程
for config in "${!configs[@]}"; do
  source="$HOME/.dotfiles/$config"
  target="${configs[$config]}"

  if [[ ! -e "$source" ]]; then
    echo "⚠️ 源不存在: $source"
    continue
  fi

  if [[ -d "$source" ]]; then
    mkdir -p "$target" # 确保目标目录存在
    link_directory "$source" "$target"
  else
    create_link "$source" "$target"
  fi
done
