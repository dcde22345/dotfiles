# dotfiles

Centralized config for my macOS terminal setup.

Managed configs:

- Ghostty: `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`
- tmux: `~/.tmux.conf`
- Neovim: `~/.config/nvim`

## Usage

Install packages and link configs:

```sh
~/dotfiles/install.sh
```

Only create symlinks:

```sh
~/dotfiles/install.sh --link-only
```

Existing files or directories are moved to `~/.config-backups/<timestamp>` before symlinks are created.
