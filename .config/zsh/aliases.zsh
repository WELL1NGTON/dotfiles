alias wget='wget --hsts-file="$XDG_DATA_HOME"/wget-hsts'
alias docker-ports='docker ps --format "table {{.Names}}\t{{.Ports}}"'
alias floorp='flatpak run one.ablaze.floorp'
alias steam='flatpak run com.valvesoftware.Steam'
alias adb='HOME="$XDG_DATA_HOME"/android adb'
alias nvidia-settings="nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings"
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"'
alias vsc="code"
if [ $TERM = "xterm-kitty" ]; then 
    alias icat='kitten icat';
    alias kssh='kitten ssh'; # kssh = kitty ssh...
fi
alias xclip="xclip -r -sel clip 1> /dev/null 2> /dev/null"

alias ls='eza --group-directories-first --icons auto'

