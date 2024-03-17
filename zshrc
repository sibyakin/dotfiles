setopt appendhistory completeinword histignorealldups histignorespace nonomatch
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C
alias ll="ls -lha"
alias vim="nvim"
alias vi="nvim"
bindkey "^[[3~" delete-char
export PS1="%n@%m%d> "
export EDITOR=nvim
export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE=$HOME/.history
export GOPATH=$HOME/Devel/golang
export PATH="$GOPATH/bin:$HOME/.bin:$PATH"
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' file-list all
zstyle ':completion:*' menu select=long
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' completer _complete _correct _approximate _history
