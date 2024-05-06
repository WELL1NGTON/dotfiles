# My Dotfiles

## Requirements

- awesomewm (git-master)

## Setup

Configs required in `/etc/security/pam_env.conf`:

```sh
XDG_CONFIG_HOME DEFAULT=@{HOME}/.config
XDG_DATA_HOME   DEFAULT=@{HOME}/.local/share
XDG_STATE_HOME  DEFAULT=@{HOME}/.local/state
XDG_CACHE_HOME  DEFAULT=@{HOME}/.cache
```

## ZSH config

Configs required in `/etc/zsh/zshenv`:

```sh
export ZDOTDIR="$HOME"/.config/zsh
```

Make sure that `$XDG_STATE_HOME/zsh` exists and is writable (also create history
file).

```sh
mkdir -p "$XDG_STATE_HOME/zsh"
touch "$XDG_STATE_HOME/zsh/history"
```

Install [oh-my-zsh](https://ohmyz.sh/), the theme
[spaceship-zsh-theme](https://github.com/spaceship-prompt/spaceship-prompt) and
the plugin
[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting).

Obs.: make sure that the environment variable `ZSH` and `ZDOTDIR` are set
correctly.

## Vim config

My neovim config is in the repo <https://github.com/WELL1NGTON/kickstart.nvim>

