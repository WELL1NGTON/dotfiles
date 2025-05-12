if [ ! -d $(dirname $HISTFILE) ]; then
    echo "$(dirname $HISTFILE)/ directory does not exist. Creating it now..."
    mkdir -p $(dirname $HISTFILE)
fi

distro_id=$(awk -F'=' '/^ID=/ {print tolower($2)}' /etc/*-release 2>/dev/null)

if [ "$distro_id" = "arch" ] && command -v yay &> /dev/null; then
    echo "${ARCHNEWS_CACHE}/ directory does not exist. Creating it now..."
    mkdir -p ${ARCHNEWS_CACHE}
fi

if command -v tldr &> /dev/null; then
    tldr --update_cache &> /dev/null &!
fi
