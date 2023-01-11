# Function from: https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathappend() {
    for ARG in "$@"; do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

# Function from: https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathprepend() {
    # for ((i=$#; i>0; i--));
    for ARG in "$@"; do
        # ARG=${!i} # This part only works in bash...
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

# ZSH
export HISTFILE="$XDG_STATE_HOME"/zsh/history

# GTK
export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc

# NPM
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc

# NVM
export NVM_DIR="$XDG_DATA_HOME"/nvm

# xinit
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc

# SSH
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh

# LOCALE
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8:pt_BR.UTF-8
export LC_ADDRESS=pt_BR.UTF-8
export LC_COLLATE=pt_BR.UTF-8
export LC_CTYPE=pt_BR.UTF-8
export LC_IDENTIFICATION=pt_BR.UTF-8
export LC_MEASUREMENT=pt_BR.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_MONETARY=pt_BR.UTF-8
export LC_NAME=pt_BR.UTF-8
export LC_NUMERIC=pt_BR.UTF-8
export LC_PAPER=pt_BR.UTF-8
export LC_TELEPHONE=pt_BR.UTF-8
export LC_TIME=pt_BR.UTF-8

# Flatapak
pathappend "/var/lib/flatpak/exports/bin"
pathappend "/var/lib/snapd/snap/bin"

# pnpm
export PNPM_HOME="$XDG_DATA_HOME"/pnpm
export PATH="$PNPM_HOME:$PATH"

# General
export TERM=alacritty
export BROWSER=firefox
export MAIL=thunderbird
export EDITOR=nvim

# .xinitrc
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
