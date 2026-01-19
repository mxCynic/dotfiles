# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:descriptions' format '[%d]'
# 强制开启补全结果分组
zstyle ':completion:*' group-name ''
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:*:*' fzf-flags --ansi
zstyle ':fzf-tab:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
# show systemd unit status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
# show file contents
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat $realpath --color=auto 2> /dev/null ||
  eza $realpath --color=always --icons --tree'
# environment variable
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
# pacman and yay preview
zstyle ':fzf-tab:complete:pacman:*' fzf-preview 'pacman -Si $word | bat --color=always -plyaml'
zstyle ':fzf-tab:complete:yay:*' fzf-preview ' yay -Si $word | bat --color=always -plyaml'

# 开启大小写不敏感补全
zstyle ':completion:*' matcher-list 'm:{a-z0-9}={A-Z0-9}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# 如果你想让补全在大小写混输时也更智能（比如输入小写匹配大写，反之亦然）
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
