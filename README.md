# My Dotfiles

## Setup

Configs required in `/etc/security/pam_env.conf`:

```sh
XDG_CONFIG_HOME DEFAULT=@{HOME}/.config
XDG_DATA_HOME   DEFAULT=@{HOME}/.local/share
XDG_STATE_HOME  DEFAULT=@{HOME}/.local/state
XDG_CACHE_HOME  DEFAULT=@{HOME}/.cache
```

Configs required in `/etc/zshenv`:

```sh
export ZDOTDIR="$HOME"/.config/zsh
```
