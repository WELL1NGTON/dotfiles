#!/bin/bash

set -Eeuo pipefail

trap 'echo "Script exited on line $LINENO with exit code $?"' EXIT
trap 'echo "Error occurred on line $LINENO"' ERR

dot_config_path=${XDG_CONFIG_HOME:-$HOME/.config}
dot_local_path=${HOME}/.local
dot_local_share_path=${XDG_DATA_HOME:-$HOME/.local/share}

DOTFILES_INSTALL_PATH=${DOTFILES_INSTALL_PATH:-${dot_local_share_path}/dotfiles}
AUTO_YES=${AUTO_YES:-false}
MODE="copy"

LANGUAGE="${LANG%%_*}"
LOCALE="${LANG%.*}"

function show_help() {
    case "$LOCALE" in
    pt_BR)
        cat <<EOF
Uso: $(basename "$0") [OPÇÕES]

Opções:
  -h            Mostrar esta mensagem de ajuda e sair
  -y            Responder 'sim' automaticamente para todas as perguntas
  -m MODO       Definir o modo como 'copy' ou 'link' para manipular os arquivos de configuração

Exemplos:
  $(basename "$0") -y -m link
EOF
        ;;
    *)
        cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h            Show this help message and exit
  -y            Automatically answer 'yes' to all prompts
  -m MODE       Set the mode to either 'copy' or 'link' for handling config files

Examples:
  $(basename "$0") -y -m link
EOF
        ;;
    esac
}

function question_y_n() {
    echo "$1 [Y/n]"
    if [ "$AUTO_YES" = true ]; then
        echo "Y"
        return 0
    else
        read -r answer
        answer=${answer^^}

        if [ -z "$answer" ]; then
            answer="Y"
        fi

        if [ "$answer" = "Y" ]; then
            return 0
        else
            return 1
        fi
    fi
}

function install_requirements_archlinux() {
    if ! command -v yay &>/dev/null; then
        if question_y_n "yay is not installed. Do you want to install yay?"; then
            sudo pacman -Syu --needed --noconfirm git base-devel
            temp_dir=$(mktemp -d)
            git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
            cd "$temp_dir/yay"
            makepkg -si --noconfirm
            cd ..
            rm -rf "$temp_dir/yay"
        else
            echo "yay is required to install the requirements."
            exit 1
        fi
    fi

    yay -Syu --noconfirm --needed \
        awesome-git \
        inotify-tools \
        sed \
        feh \
        playerctl \
        network-manager-applet \
        nitrogen \
        adwaita-icon-theme \
        adwaita-icon-theme-legacy \
        breeze-gtk \
        breeze-icons \
        papirus-icon-theme \
        ca-certificates \
        picom \
        xbindkeys \
        xclip \
        clipnotify \
        glib2 \
        dex \
        lightdm \
        lightdm-gtk-greeter \
        lightdm-gtk-greeter-settings \
        light-locker \
        polkit \
        polkit-gnome \
        seahorse \
        pasystray \
        xdg-utils \
        xdg-desktop-portal \
        xdg-desktop-portal-gtk \
        kitty \
        neovim \
        zsh \
        thefuck \
        tldr \
        pyenv \
        zoxide \
        ripgrep \
        fastfetch \
        bpytop \
        man-pages \
        man-db \
        man-pages-pt_BR \
        networkmanager \
        bluez \
        bluez-utils \
        bluez-deprecated-tools \
        blueman \
        flameshot \
        pcmanfm-gtk3 \
        gvfs \
        gvfs-smb \
        gvfs-mtp \
        flatpak \
        pipewire \
        pipewire-pulse \
        wireplumber \
        mpv \
        ttf-fira-code \
        ttf-fira-sans \
        ttf-firacode-nerd \
        noto-fonts \
        noto-fonts-extra \
        noto-fonts-emoji \
        noto-fonts-cjk \
        adobe-source-code-pro-fonts \
        font-manager \
        tesseract \
        tesseract-data-eng \
        tesseract-data-jpn \
        tesseract-data-jpn_vert \
        tesseract-data-osd \
        tesseract-data-por \
        pandoc-cli
    # synergy3-bin \
    # cbatticon \ # not needed, unless it is being installed in a notebook
    # floorp-bin # not sure if install floorp from AUR or flatpak...

    # flatpak remote-add --user flathub https://flathub.org/repo/flathub.flatpakrepo
    # flatpak install --noninteractive --user it.mijorus.smile
    # flatpak install --noninteractive com.valvesoftware.Steam

    flatpak install --noninteractive --system \
        com.github.tchx84.Flatseal \
        one.ablaze.floorp \
        com.belmoussaoui.Authenticator \
        com.usebottles.bottles \
        it.mijorus.gearlever
}

function configure_pam_env() {
    pam_env_file="/etc/security/pam_env.conf"
    if [ ! -f $pam_env_file ]; then
        echo "PAM env file not found!"
        exit 1
    fi
    if ! grep -q "XDG_CONFIG_HOME" $pam_env_file; then
        echo "XDG_CONFIG_HOME DEFAULT=@{HOME}/.config" | sudo tee -a $pam_env_file
    fi
    if ! grep -q "XDG_DATA_HOME" $pam_env_file; then
        echo "XDG_DATA_HOME   DEFAULT=@{HOME}/.local/share" | sudo tee -a $pam_env_file
    fi
    if ! grep -q "XDG_STATE_HOME" $pam_env_file; then
        echo "XDG_STATE_HOME  DEFAULT=@{HOME}/.local/state" | sudo tee -a $pam_env_file
    fi
    if ! grep -q "XDG_CACHE_HOME" $pam_env_file; then
        echo "XDG_CACHE_HOME  DEFAULT=@{HOME}/.cache" | sudo tee -a $pam_env_file
    fi
}

function configure_zdotdir_var() {
    zshenv_file="/etc/zsh/zshenv"
    if [ ! -f $zshenv_file ]; then
        echo "Zsh env file not found, creating it!"
        sudo touch $zshenv_file
    fi
    if ! grep -q "ZDOTDIR" $zshenv_file; then
        echo "ZDOTDIR=$HOME/.config/zsh" | sudo tee -a $zshenv_file
    fi
}

function install_config() {
    if [ "$MODE" = "copy" ]; then
        if [ -f "$1" ] || [ -d "$1" ] || [ -L "$1" ]; then
            if question_y_n "$1 configuration already exists. Overwrite?"; then
                rm -rf "$1"
                cp -r "$2" "$1"
            fi
        else
            cp -r "$2" "$1"
        fi
    elif [ "$MODE" = "link" ]; then
        if [ -f "$1" ] || [ -d "$1" ] || [ -L "$1" ]; then
            if question_y_n "$1 configuration already exists. Overwrite?"; then
                rm -rf "$1"
                ln -sf "$2" "$1"
            fi
        else
            ln -s "$2" "$1"
        fi
    fi
}

function is_os_archlinux() {
    if [ -f /etc/arch-release ]; then
        return 0
    else
        return 1
    fi
}

function enable_services() {
    if [ "$AUTO_YES" = true ]; then
        sudo systemctl enable lightdm.service
        sudo systemctl enable bluetooth.service
        sudo systemctl enable NetworkManager.service
        systemctl --user enable pipewire.service
        systemctl --user enable pipewire-pulse.service
        systemctl --user enable wireplumber.service
    else
        if question_y_n "Do you want to enable lightdm, bluetooth, NetworkManager, pipewire and wireplumber services?"; then
            sudo systemctl enable lightdm.service
            sudo systemctl enable bluetooth.service
            sudo systemctl enable NetworkManager.service
            systemctl --user enable pipewire.service
            systemctl --user enable pipewire-pulse.service
            systemctl --user enable wireplumber.service
        fi
    fi
}

function generate_locales() {
    if [ "$AUTO_YES" = true ]; then
        sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        sudo sed -i 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
        sudo locale-gen
        sudo localectl set-locale LANG=en_US.UTF-8
        sudo localectl set-locale LC_CTYPE=pt_BR.UTF-8
        sudo localectl set-locale LC_NUMERIC=pt_BR.UTF-8
        sudo localectl set-locale LC_TIME=pt_BR.UTF-8
        sudo localectl set-locale LC_COLLATE=pt_BR.UTF-8
        sudo localectl set-locale LC_MONETARY=pt_BR.UTF-8
        sudo localectl set-locale LC_MESSAGES=en_US.UTF-8
        sudo localectl set-locale LC_PAPER=pt_BR.UTF-8
        sudo localectl set-locale LC_NAME=pt_BR.UTF-8
        sudo localectl set-locale LC_ADDRESS=pt_BR.UTF-8
        sudo localectl set-locale LC_TELEPHONE=pt_BR.UTF-8
        sudo localectl set-locale LC_MEASUREMENT=pt_BR.UTF-8
        sudo localectl set-locale LC_IDENTIFICATION=pt_BR.UTF-8
    else
        if question_y_n "Do you want to generate locales?"; then
            sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
            sudo sed -i 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
            sudo locale-gen
            sudo localectl set-locale LANG=en_US.UTF-8
            sudo localectl set-locale LC_CTYPE=pt_BR.UTF-8
            sudo localectl set-locale LC_NUMERIC=pt_BR.UTF-8
            sudo localectl set-locale LC_TIME=pt_BR.UTF-8
            sudo localectl set-locale LC_COLLATE=pt_BR.UTF-8
            sudo localectl set-locale LC_MONETARY=pt_BR.UTF-8
            sudo localectl set-locale LC_MESSAGES=en_US.UTF-8
            sudo localectl set-locale LC_PAPER=pt_BR.UTF-8
            sudo localectl set-locale LC_NAME=pt_BR.UTF-8
            sudo localectl set-locale LC_ADDRESS=pt_BR.UTF-8
            sudo localectl set-locale LC_TELEPHONE=pt_BR.UTF-8
            sudo localectl set-locale LC_MEASUREMENT=pt_BR.UTF-8
            sudo localectl set-locale LC_IDENTIFICATION=pt_BR.UTF-8
        fi
    fi
}

while getopts "hym:" opt; do
    case ${opt} in
    h)
        show_help
        exit 0
        ;;
    y)
        AUTO_YES=true
        ;;
    m)
        if [[ "$OPTARG" != "copy" && "$OPTARG" != "link" ]]; then
            echo "Error: Invalid mode '$OPTARG'. Use 'copy' or 'link'."
            exit 1
        fi
        MODE="$OPTARG"
        ;;
    *)
        show_help
        exit 1
        ;;
    esac
done

if [ "$EUID" -eq 0 ]; then
    echo "This script should not be run as root. Please run it as a normal user."
    exit 1
fi

echo "This script needs sudo permissions to install packages and enable services"
if ! sudo -v; then
    echo "Failed to obtain sudo permissions. Exiting."
    exit 1
fi

if is_os_archlinux; then
    if question_y_n "Do you want to install and configure requirements?"; then
        echo "Installing requirements..."
        install_requirements_archlinux
        echo "Configuring pam_env..."
        configure_pam_env
        echo "Configuring zshenv..."
        configure_zdotdir_var
    fi
fi

if [ ! -d "$DOTFILES_INSTALL_PATH" ]; then
    echo "DOTFILES_INSTALL_PATH does not exist. Cloning the repository..."
    DOTFILES_INSTALL_PATH_PARENT=$(dirname "$DOTFILES_INSTALL_PATH")
    if [ ! -d "$DOTFILES_INSTALL_PATH_PARENT" ]; then
        mkdir -p "$DOTFILES_INSTALL_PATH_PARENT"
    fi

    repo_https="https://github.com/WELL1NGTON/dotfiles.git"
    repo_ssh="git@github.com:WELL1NGTON/dotfiles.git"

    if ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 | grep -q "successfully authenticated"; then
        echo "SSH authentication successful. Cloning via SSH..."
        git clone "$repo_ssh" "$DOTFILES_INSTALL_PATH"
    else
        echo "SSH authentication failed or not configured. Cloning via HTTPS..."
        git clone "$repo_https" "$DOTFILES_INSTALL_PATH"
    fi
    git submodule update --init --recursive
else
    echo "DOTFILES_INSTALL_PATH already exists. Updating..."
    cd "$DOTFILES_INSTALL_PATH"
    git fetch origin
    if git pull --ff-only; then
        echo "Repository updated successfully."
    else
        echo "Failed to update the repository. Do you want to reset it? [Y/n]"
        if [ "$AUTO_YES" = true ]; then
            echo "Y"
            git reset --hard origin/main
        else
            read -r answer
            answer=${answer^^}

            if [ -z "$answer" ]; then
                answer="Y"
            fi

            if [ "$answer" = "Y" ]; then
                git reset --hard origin/main
            else
                echo "Exiting without resetting the repository."
                exit 1
            fi
        fi
    fi
    git submodule update --init --recursive
fi

echo "DOTFILES_INSTALL_PATH exists, continuing with the script..."
cd "$DOTFILES_INSTALL_PATH"
if [ ! -d "$dot_config_path" ]; then
    mkdir -p "$dot_config_path"
fi
install_config "${dot_config_path}"/alacritty "${DOTFILES_INSTALL_PATH}"/.config/alacritty
install_config "${dot_config_path}"/awesome "${DOTFILES_INSTALL_PATH}"/.config/awesome
install_config "${dot_config_path}"/fastfetch "${DOTFILES_INSTALL_PATH}"/.config/fastfetch
install_config "${dot_config_path}"/git "${DOTFILES_INSTALL_PATH}"/.config/git
install_config "${dot_config_path}"/gtk-2.0 "${DOTFILES_INSTALL_PATH}"/.config/gtk-2.0
install_config "${dot_config_path}"/gtk-3.0 "${DOTFILES_INSTALL_PATH}"/.config/gtk-3.0
install_config "${dot_config_path}"/gtk-4.0 "${DOTFILES_INSTALL_PATH}"/.config/gtk-4.0
install_config "${dot_config_path}"/kitty "${DOTFILES_INSTALL_PATH}"/.config/kitty
install_config "${dot_config_path}"/luarocks "${DOTFILES_INSTALL_PATH}"/.config/luarocks
install_config "${dot_config_path}"/npm "${DOTFILES_INSTALL_PATH}"/.config/npm
install_config "${dot_config_path}"/nvim "${DOTFILES_INSTALL_PATH}"/.config/nvim
install_config "${dot_config_path}"/pcmanfm "${DOTFILES_INSTALL_PATH}"/.config/pcmanfm
install_config "${dot_config_path}"/picom "${DOTFILES_INSTALL_PATH}"/.config/picom
install_config "${dot_config_path}"/spotify-player "${DOTFILES_INSTALL_PATH}"/.config/spotify-player
install_config "${dot_config_path}"/X11 "${DOTFILES_INSTALL_PATH}"/.config/X11
install_config "${dot_config_path}"/xbindkeys "${DOTFILES_INSTALL_PATH}"/.config/xbindkeys
install_config "${dot_config_path}"/zsh "${DOTFILES_INSTALL_PATH}"/.config/zsh
install_config "${dot_config_path}"/mimeapps.list "${DOTFILES_INSTALL_PATH}"/.config/mimeapps.list
install_config "${dot_config_path}"/gtk-4.0 "${DOTFILES_INSTALL_PATH}"/.config/gtk-4.0

local_bin_path=${dot_local_path}/bin
if [ ! -d "$local_bin_path" ]; then
    mkdir -p "$local_bin_path"
fi
install_config "${local_bin_path}"/clip-persist "${DOTFILES_INSTALL_PATH}"/.local/bin/clip-persist
install_config "${local_bin_path}"/devc-start "${DOTFILES_INSTALL_PATH}"/.local/bin/devc-start
install_config "${local_bin_path}"/flameshot-ocr "${DOTFILES_INSTALL_PATH}"/.local/bin/flameshot-ocr
install_config "${local_bin_path}"/mdpreview "${DOTFILES_INSTALL_PATH}"/.local/bin/mdpreview
install_config "${local_bin_path}"/set-wallpaper "${DOTFILES_INSTALL_PATH}"/.local/bin/set-wallpaper

install_config "${HOME}"/.xprofile "${DOTFILES_INSTALL_PATH}"/.xprofile

if question_y_n "Do you want to enable lightdm, bluetooth, NetworkManager, pipewire and wireplumber services?"; then
    enable_services
fi

if question_y_n "Change the default shell to zsh?"; then
    user=$(whoami)
    sudo chsh -s "$(which zsh)" "$user"
fi

AUTO_YES=false
if question_y_n "Do you want to reboot now?"; then
    echo "Rebooting..."
    sudo reboot now
fi
