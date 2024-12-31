HISTFILESIZE=10000000
HISTSIZE=100000
SAVEHIST=50000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

if [ ! -d $(dirname $HISTFILE) ]; then
    echo "$(dirname $HISTFILE)/ directory does not exist. Creating it now..."
    mkdir -p $(dirname $HISTFILE)
fi

ARCHNEWS_DATES="${XDG_CACHE_HOME:-$HOME/.cache}/archlinux-news/dates"
if [ ! -d $ARCHNEWS_DATES ]; then
    echo "$(dirname $ARCHNEWS_DATES)/ directory does not exist. Creating it now..."
    mkdir -p $(dirname $ARCHNEWS_DATES)
fi

# Default Keyboard config
# US International
# setxkbmap us -variant intl
# PT-BR ABNT2
# setxkbmap -model pc105 -layout br -variant abnt2

# # Disable the screensaver
# xset s off
# xset -dpms
# xset s noblank

# # Disable the screen lock
# xautolock -disable

# # Disable the screen blanking
# xset s off
# xset -dpck
# xset s noblank

# https://bbs.archlinux.org/viewtopic.php?id=251330
