export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
export HISTFILESIZE=10000000
export HISTSIZE=100000
export SAVEHIST=50000

# TODO: remove from zprofile tldr update
if command -v tldr &> /dev/null; then
    tldr --update_cache &> /dev/null &!
fi

# Awesome
export AWESOME_THEMES_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/awesome/themes"

# Android
export ANDROID_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/android"

# ZSH
export ZSH="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ohmyzsh"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"
export ARCHNEWS_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/archlinux-news"
export ARCHNEWS_CACHE_LIFETIME=21600
export ARCHNEWS_SHORT="${ARCHNEWS_CACHE}/short"
export ARCHNEWS_FULL="${ARCHNEWS_CACHE}/full"
export ARCHNEWS_DAYS=14

# GTK
export GTK_THEME="Breeze-Dark"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc"

# QT
# export QT_QPA_PLATFORMTHEME=qt5ct
export QT_QPA_PLATFORMTHEME=kvantum
export QT_STYLE_OVERRIDE=kvantum

# xinit
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/X11/xinitrc"

# SSH
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh

# AZURE
export AZURE_CONFIG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/azure"

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

# Azure
export AZURE_CONFIG_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/azure

# Node
export NODE_REPL_HISTORY="${XDG_DATA_HOME:-$HOME/.local/share}/node_repl_history"
export COREPACK_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/node/corepack"

# npm
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/npmrc"

# NVM
export NVM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"

# pnpm
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"

# General
export TERM=xterm-kitty
export BROWSER=one.ablaze.floorp
export MAIL=eu.betterbird.Betterbird
export EDITOR=nvim
export CUDA_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/nv"

# DOTNET
# https://bbs.archlinux.org/viewtopic.php?id=251330
export ASPNETCORE_Kestrel__Certificates__Default__Password="" # No password
export ASPNETCORE_Kestrel__Certificates__Default__Path="${XDG_DATA_HOME}/.aspnet/https/aspnetapp.pfx"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_CLI_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/dotnet"
export NUGET_PACKAGES="${XDG_CACHE_HOME:-$HOME/.cache}/NuGetPackages"
export OMNISHARPHOME="${XDG_CONFIG_HOME:-$HOME/.config}/omnisharp"

# Steam
export STEAM_FORCE_DESKTOPUI_SCALING=1

# Docker
# export DOCKER=podman
export DOCKER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/docker"

# Minikube
export MINIKUBE_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/minikube"
export KUBECONFIG="$MINIKUBE_HOME/profiles/minikube/config"

# cargo
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"

# go
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"

# aws
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/aws/credentials"
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/aws/config"

# w3m
export W3M_DIR="$XDG_STATE_HOME/w3m"

zprofile_local="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zprofile.local"

if [ -f $zprofile_local ]; then
    source $zprofile_local
fi