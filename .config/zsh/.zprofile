if [ ! -d $(dirname $HISTFILE) ]; then
    echo "$(dirname $HISTFILE)/ directory does not exist. Creating it now..."
    mkdir -p $(dirname $HISTFILE)
fi

distro_id=$(awk -F'=' '/^ID=/ {print tolower($2)}' /etc/*-release 2>/dev/null)

echo "Testing if .zprofile is reading .zshenv: $ARCHNEWS_CACHE, $LANGUAGE, $EDITOR" >> /home/wellington/.zprofile.log

if [ "$distro_id" = "arch" ] && command -v yay &> /dev/null; then
    echo "${ARCHNEWS_CACHE}/ directory does not exist. Creating it now..."
    mkdir -p ${ARCHNEWS_CACHE}
fi

if command -v tldr &> /dev/null; then
    tldr --update_cache &> /dev/null &!
fi

if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/X11/xresources" ]; then
    xrdb -load ~/.config/X11/xresources
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
