setopt appendhistory completeinword histignorealldups histignorespace nonomatch
alias vi="nvim"
alias vim="nvim"
alias ll="ls -lha"
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
export PS1="%n@%m%d> "
export KEYTIMEOUT=1
export HISTSIZE=8184
export SAVEHIST=8184
export HISTFILE=$HOME/.history
export GOPATH=$HOME/Devel/golang
export PATH="$HOME/.bin:$GOPATH/bin:$PATH"
zstyle ':completion:*' file-list all
zstyle ':completion:*' menu select=long
zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' matcher-list "m:{a-zA-Z}={A-Za-z}"
