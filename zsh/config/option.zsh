### 记一些杂七杂八的属性
#
#
###

# 找到 WORDCHARS 并删掉其中的 / 
# 如果你发现其他符号（如 . 或 _）也碍事，也可以一并删掉
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# 启用命令执行时长记录
setopt INC_APPEND_HISTORY_TIME

# 确保禁用其他可能导致时长为0的选项 (如果它们被默认或Oh My Zsh启用)
unsetopt INC_APPEND_HISTORY
unsetopt SHARE_HISTORY
