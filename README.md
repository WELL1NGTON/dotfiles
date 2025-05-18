# My Dotfiles

## Install from github script

```sh
# download, customize and run the script
curl -sSL https://raw.githubusercontent.com/WELL1NGTON/dotfiles/refs/heads/master/install-dotfiles.sh -o install-dotfiles.sh
# You can use -y to skip the confirmation prompts. However every conflict in
# .config will be overwritten if you use -y.
# And -m can be "link" or "copy" to indicate if you want to create symlinks or
# copy the files to ~/.config.
bash install-dotfiles.sh -m link # -y for skipping confirmation
```

## Manual install

### Setup

Configs required in `/etc/security/pam_env.conf`:

```sh
XDG_CONFIG_HOME DEFAULT=@{HOME}/.config
XDG_DATA_HOME   DEFAULT=@{HOME}/.local/share
XDG_STATE_HOME  DEFAULT=@{HOME}/.local/state
XDG_CACHE_HOME  DEFAULT=@{HOME}/.cache
```

### ZSH config

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

### Copy configs

```sh
mkdir -p ~/.config
cp -r .config/* ~/.config
```

## Vim config

My neovim config is in the repo <https://github.com/WELL1NGTON/kickstart.nvim>
