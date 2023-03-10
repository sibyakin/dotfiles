unsetopt nomatch
setopt appendhistory completeinword histignorealldups histignorespace

alias find="fd"
alias grep="rg"
alias ll="ls -lha"
alias vi="nvim"

autoload -Uz compinit
if [ ! -f "$HOME/.zcompdump" ]; then
    compinit
else
    if [ $(($(date +%s)-$(stat -c "%W" "$HOME/.zcompdump"))) -gt 86400 ]; then
        compinit
    else
        compinit -C
    fi
fi

bindkey "^B" backward-word
bindkey "^F" forward-word
bindkey "^[[3~" delete-char

export PS1="%n@%m:%d> "
export HISTSIZE=65535
export SAVEHIST=65535
export HISTFILE=$HOME/.zsh_hist
export TERM=xterm-256color
export EDITOR=vi
export GOTELEMETRY=off
export GOPATH=$HOME/Devel/golang
if ! [[ "$PATH" =~ "$HOME/bin" ]]
then
    PATH="$HOME/bin:$PATH"
fi
if ! [[ "$PATH" =~ "$GOPATH/bin" ]]
then
    PATH="$GOPATH/bin:$PATH"
fi
export PATH

zstyle ':completion:*' file-list all
zstyle ':completion:*' menu select=long
zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' matcher-list "m:{a-zA-Z}={A-Za-z}"
