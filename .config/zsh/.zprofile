if command -v tldr &> /dev/null; then
    tldr --update_cache &> /dev/null &!
fi

zprofile_local="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zprofile.local"

if [ -f $zprofile_local ]; then
    source $zprofile_local
fi
