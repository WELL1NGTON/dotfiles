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

# Android Studio
export ANDROID_HOME="$XDG_DATA_HOME"/android

# ZSH
export HISTFILE="$XDG_STATE_HOME"/zsh/history

# GTK
export GTK_THEME=Adwaita:dark

# NVM
export NVM_DIR="$XDG_DATA_HOME"/nvm

# .NET config
export DOTNET_ROOT=/usr/share/dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export CLR_ICU_VERSION_OVERRIDE=72.1
pathappend "/home/wellington/.dotnet/tools"

# PATH
pathappend "/var/lib/flatpak/exports/bin"
pathappend "/var/lib/snapd/snap/bin"
pathprepend "$HOME/bin" "$HOME/.local/bin"

# General
export TERM=alacritty
export BROWSER=firefox
export MAIL=thunderbird
export EDITOR=nvim

# KDE Plasma
# export PLASMA_USE_QT_SCALING=1

# Android
#export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_HOME="/opt/android-sdk"
#export ANDROID_SDK=/opt/android-sdk
#pathappend "$ANDROID_HOME/tools"
#pathappend "$ANDROID_HOME/platform-tools"
export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
