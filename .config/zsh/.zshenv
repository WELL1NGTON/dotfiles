zshenv_local="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zshenv.local"
if [ -f $zshenv_local ]; then
    source $zshenv_local
fi
