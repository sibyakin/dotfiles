export PROMPT="%n@%m%d> "
export HISTSIZE=2000
export SAVEHIST=2000
export HISTFILE=$HOME/.history

[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'
