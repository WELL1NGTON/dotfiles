HISTFILESIZE=10000000
HISTSIZE=100000
SAVEHIST=50000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

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
  # dotnet
  pip
  docker
  docker-compose
  #  firewalld

  # > source https://github.com/zsh-users/zsh-syntax-highlighting
  zsh-syntax-highlighting

  # https://python-poetry.org/docs/#installing-with-the-official-installer
  poetry
)

source ${ZSH:-$HOME/.local/share/oh-my-zsh}/oh-my-zsh.sh

eval $(thefuck --alias)

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(zoxide init zsh)"

source ${ZDOTDIR:-"$XDG_CONFIG_HOME"/zsh}/aliases.zsh

fastfetch

