ZSH_THEME="spaceship"

VSCODE=code-insiders

plugins=(
  git
  dotnet
  pip
  docker
  docker-compose
  #  firewalld
  #  frontend-search
  #  web-search
  #  thefuck

  vscode

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

