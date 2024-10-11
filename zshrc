setopt appendhistory completeinword histignorealldups histignorespace nonomatch
autoload -Uz compinit; compinit
alias ll="ls -lha"
alias vim="nvim"
alias vi="nvim"
bindkey "^[[3~" delete-char
export PS1="%n@%m%d> "
export EDITOR=nvim
export HISTSIZE=2000
export SAVEHIST=2000
export HISTFILE=$HOME/.history
export GOPATH=$HOME/Devel/golang
export PATH="$GOPATH/bin:$HOME/.bin:$PATH"
zstyle ':completion:*' file-list all
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' completer _complete _approximate
