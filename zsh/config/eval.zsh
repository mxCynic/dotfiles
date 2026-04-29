# starship
# eval "$(starship init zsh)"

# pyenv 
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# PAGER=cat 
eval "$(atuin init zsh)"
bindkey "^P" atuin-up-search
bindkey "^N" atuin-down-search

eval "$(zoxide init zsh)"

eval "$(starship init zsh)"

eval "$(COMPLETE=zsh jj)"

