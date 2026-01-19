# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:~/.mxbin/
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/
export PATH=$PATH:~/.ghcup/bin/
export PATH=$PATH:/opt/cuda/bin/:$PATH
export PATH=$PATH:~/.config/hypr/scripts/
export PATH=$PATH:/opt/nvidia/hpc_sdk/Linux_x86_64/2025/compilers/bin
export PATH=$HOME/.elan/bin:$PATH
# export PATH="$HOME/.elan/env:$PATH"

export EDITOR='nvim'

export GTK_MODULES=unity-gtk-module

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export LESSOPEN='|~/.lessfilter %s'

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# uv pip mirrors
export UV_DEFAULT_INDEX="https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"

export GEMINI_API_KEY=AIzaSyDj6-hK0rDoU_wtU_zfoKj0MvHmwrVaMlA

# C和CPP环境
export CC=gcc-11
export CXX=g++-11

export ZED_DEVELOPMENT_USE_KEYCHAIN=1

export STARSHIP_CONFIG=~/.config/starship/starship.toml
