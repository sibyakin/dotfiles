setopt appendhistory completeinword histignorespace nonomatch
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
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=$HOME/.history
export GOPATH=$HOME/Devel/golang
export PATH="$GOPATH/bin:$HOME/.bin:$PATH"
zstyle ':completion:*' file-list all
zstyle ':completion:*' menu select=3
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*' max-errors 3 numeric
