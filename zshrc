# Enable Powerlevel9k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:~/Mxbin/bin/
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/
export PATH=$PATH:~/.ghcup/bin/
export PATH=$PATH:/opt/cuda/bin/:$PATH
export PATH=$HOME/.config/rofi/scripts:$PATH
export PATH=$PATH:~/.config/hypr/scripts/




# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# case_sensitive="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
# show systemd unit status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
# show file contents
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat $realpath --color=auto 2> /dev/null ||
  eza $realpath --color=always --icons --tree'
export LESSOPEN='|~/.lessfilter %s'
# environment variable
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
# pacman and yay preview
zstyle ':fzf-tab:complete:pacman:*' fzf-preview 'pacman -Si $word | bat --color=always -plyaml'
zstyle ':fzf-tab:complete:yay:*' fzf-preview ' yay -Si $word | bat --color=always -plyaml'


# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
plugins=(
    # other plugins...
    zsh-autosuggestions  # 插件之间使用空格隔开
    zsh-syntax-highlighting
    z
    zsh-eza
)
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

source $ZSH/oh-my-zsh.sh
source ~/.config/fzf-tab/fzf-tab.plugin.zsh
source ~/.oh-my-zsh/plugins/fsh/

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
export EDITOR='nvim';
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim=nvim
alias bdwp="~/Mxbin/baidudisk/opt/baidunetdisk/baidunetdisk"
alias matlab="~/matlab/R2022b/bin/matlab -nosplash -nodesktop"
alias chkit="GLFW_IM_MODULE=ibus kitty"
alias kicat="kitty +kitten icat"
alias hl="Hyprland"
alias read="zathura"
alias battery="upower -i `upower -e | grep 'BAT'`"
alias mf="musicfox"
alias ct="countdown"
alias mv="mv -i"
alias lg="lazygit"
alias svim="sudo -E nvim"
alias dolist="todoist-cli"

# python go to visiual environment
pe ()
{
  if [ -f "pyvenv.cfg" ]; then
    source bin/activate
  else
    echo "No visiual environment"
  fi
}


#  设置 socket 代理(clash)
export http_proxy=socks5://127.0.0.1:7891
export https_proxy=socks5://127.0.0.1:7891

spro(){
 export http_proxy=socks5://127.0.0.1:7891
 export https_proxy=socks5://127.0.0.1:7891
}
hpro(){
 export http_proxy=http://127.0.0.1:7891
 export https_proxy=https://127.0.0.1:7891
}

upro(){
 export http_proxy=
 export https_proxy=
 export ALL_PROXY=
}

export GTK_MODULES=unity-gtk-module
# git peoxy
git config --global http.proxy 'socks5://127.0.0.1:7891' 
git config --global https.proxy 'socks5://127.0.0.1:7891'

# starship
 eval "$(starship init zsh)"

if [ -n "${NVIM_LISTEN_ADDRESS+x}" ]; then
  export MANPAGER="/usr/local/bin/nvr -c 'Man!' -o -"
fi


# pyenv 
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

