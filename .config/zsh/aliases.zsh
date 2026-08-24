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

if command -v eza &> /dev/null; then
    alias eza='eza --group-directories-first --group'
    alias e='eza --group-directories-first --group'
    alias el='eza --group-directories-first --group -l'
    alias ea='eza --group-directories-first --group -al'
    alias et='eza --group-directories-first --group -alT'
fi

alias myip='curl -s ifconfig.me'
alias whereami='curl -s ipinfo.io/$(curl -s ifconfig.me) | jq .'
