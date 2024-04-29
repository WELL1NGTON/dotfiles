# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$XDG_DATA_HOME/oh-my-zsh"

ZSH_THEME="spaceship"

VSCODE=code-insiders

plugins=(
  git
  #  git-prompt
  dotnet
  pip
  docker
  docker-compose
  # tmux
  #  firewalld
  #  frontend-search
  #  web-search
  #  thefuck

  #  https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
  # vi-mode

  vscode

  # > source https://github.com/zsh-users/zsh-autosuggestions
  #  zsh-autosuggestions

  # > source https://github.com/zsh-users/zsh-syntax-highlighting
  zsh-syntax-highlighting

  # https://python-poetry.org/docs/#installing-with-the-official-installer
  poetry
)

source $ZSH/oh-my-zsh.sh

if [ -d '/usr/share/nvm' ]; then
  source /usr/share/nvm/init-nvm.sh
fi

source "$XDG_CONFIG_HOME"/zsh/aliases

fastfetch

eval $(thefuck --alias)

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
