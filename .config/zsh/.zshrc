setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

# PATH
PATH="$HOME/.local/bin:${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin:$PNPM_HOME:$GOPATH/bin:$HOME/.cargo/bin:$HOME/.dotnet/tools:$HOME/.local/share/dotnet/tools:$PATH:/var/lib/flatpak/exports/bin:/var/lib/snapd/snap/bin"

ZSH_THEME="spaceship"

if [ ! -d ${ZSH:-$HOME/.local/share/oh-my-zsh} ]; then
  ZSH=${ZSH:-$HOME/.local/share/oh-my-zsh} git clone https://github.com/ohmyzsh/ohmyzsh.git $ZSH
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.local/share/oh-my-zsh}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_CUSTOM:-$HOME/.local/share/oh-my-zsh}/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.local/share/oh-my-zsh}/themes/spaceship-prompt" ]; then
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git \
    "${ZSH_CUSTOM:-$HOME/.local/share/oh-my-zsh}/themes/spaceship-prompt" \
    --depth=1
  ln -s "${ZSH_CUSTOM:-$HOME/.local/share/oh-my-zsh}/themes/spaceship-prompt/spaceship.zsh-theme" \
    "${ZSH_CUSTOM:-$HOME/.local/share/oh-my-zsh}/themes/spaceship.zsh-theme"
fi

plugins=(
  git
  dotnet
  pip
  docker
  docker-compose
  firewalld

  # > source https://github.com/zsh-users/zsh-syntax-highlighting
  zsh-syntax-highlighting

  # https://python-poetry.org/docs/#installing-with-the-official-installer
  # poetry
)

source ${ZSH:-$HOME/.local/share/oh-my-zsh}/oh-my-zsh.sh

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(zoxide init zsh)"

source ${ZDOTDIR:-"$XDG_CONFIG_HOME"/zsh}/aliases.zsh

fastfetch

distro_id=$(awk -F'=' '/^ID=/ {print tolower($2)}' /etc/*-release 2>/dev/null)

if [ "$distro_id" = "arch" ]; then
  source $ZDOTDIR/arch-scripts.zsh
fi
