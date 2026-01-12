### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-completions
zinit light z-shell/zsh-eza

# Atuin (替换原 eval)
zinit ice wait"0" lucid atload'eval "$(atuin init zsh)"'
zinit snippet /dev/null

# Zoxide (替换原 eval)
zinit ice wait"0" lucid atload'eval "$(zoxide init zsh)"'
zinit snippet /dev/null
#
source ~/.config/zsh/zstyle.zsh
zinit snippet OMZ::lib/directories.zsh

autoload -Uz compinit
compinit
zinit light Aloxaf/fzf-tab
# zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting
zinit light catppuccin/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
