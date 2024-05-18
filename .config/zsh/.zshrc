export HISTFILESIZE=10000000
export HISTSIZE=100000
export SAVEHIST=50000
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

ZSH_THEME="spaceship"

if [ ! -d ${ZSH:-$HOME/.local/share/oh-my-zsh} ]; then
  ZSH=${ZSH:-$HOME/.local/share/oh-my-zsh} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

