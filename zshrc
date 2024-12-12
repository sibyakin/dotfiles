setopt appendhistory completeinword histignorealldups histignorespace nonomatch
autoload -Uz compinit; compinit
alias ll="ls -lha"
alias vim="nvim"
alias vi="nvim"
bindkey "^[[3~" delete-char
bindkey "^R" history-incremental-search-backward
zstyle ':completion:*' file-list all
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' completer _complete _approximate
