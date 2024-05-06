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
    for ARG in "$@"; do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        else
            # remove ARG from path and add it to the start
            PATH=$(echo $PATH | sed "s|:\{0,1\}$ARG:\{0,1\}|:|g")
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

# Awesome
export AWESOME_THEMES_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/awesome/themes"

# Android
export ANDROID_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/android"

# ZSH
export ZSH="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ohmyzsh"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"
export COMPLETION_WAITING_DOTS=true
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

# GTK
export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc"

# NVM
export NVM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"

# xinit
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/X11/xinitrc"

# SSH
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh

# AZURE
export AZURE_CONFIG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/azure"

# NUGET
export NUGET_PACKAGES="${XDG_CACHE_HOME:-$HOME/.cache}/NuGetPackages"

# gnupg
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"

# Python
export PYENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/pyenv
export PYTHONPYCACHEPREFIX=${XDG_CACHE_HOME:-$HOME/.cache}/python
export PYTHONUSERBASE=${XDG_DATA_HOME:-$HOME/.local/share}/python
export POETRY_HOME=${XDG_DATA_HOME:-$HOME/.local/share}/pypoetry
export WORKON_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/virtualenvs"
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export PIP_REQUIRE_VIRTUALENV=true
pathappend $POETRY_HOME/bin
export PYENV_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/pyenv"

# Azure
export AZURE_CONFIG_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/azure

# LOCALE
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en:C:pt_BR
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
pathappend "$HOME/.local/bin"

# Node
export NODE_REPL_HISTORY="${XDG_DATA_HOME:-$HOME/.local/share}/node_repl_history"
export COREPACK_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/node/corepack"

# npm
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/npmrc"
pathappend "${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin"

# pnpm
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
export PATH="$PNPM_HOME:$PATH"

# General
# export TERM=alacritty
export BROWSER=one.ablaze.floorp
export MAIL=thunderbird
export EDITOR=nvim
export CUDA_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/nv"

# .xinitrc
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/X11/xinitrc"

# https://bbs.archlinux.org/viewtopic.php?id=251330
export ASPNETCORE_Kestrel__Certificates__Default__Password="" # No password
export ASPNETCORE_Kestrel__Certificates__Default__Path="${XDG_DATA_HOME}/.aspnet/https/aspnetapp.pfx"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_CLI_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/dotnet"
export OMNISHARPHOME="${XDG_CONFIG_HOME:-$HOME/.config}/omnisharp"
pathappend "$DOTNET_CLI_HOME/.dotnet/tools"

# Steam
export STEAM_FORCE_DESKTOPUI_SCALING=1

# Docker
export DOCKER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/docker"

# cargo
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"

# go
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
