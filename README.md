# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io). Works on Linux (bash) and macOS (zsh).

## Install

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply magnusdalkvist
```

Requires `brew` (macOS) or `apt` (Linux) — the setup scripts handle the rest.

## What's included

| File | Purpose |
|------|---------|
| `.tmux.conf` | Prefix `Ctrl+Space`, pane nav, vi copy mode, clipboard |
| `.zshrc` / `.bashrc` | Prompt, aliases, PATH, history |
| `.bash_aliases` | Shared aliases across bash and zsh |
| `.theme.omp.json` | [oh-my-posh](https://ohmyposh.dev) prompt theme |
| `.config/nvim` | Neovim config |

## tmux scripts

| Script | Purpose |
|--------|---------|
| `tmux-start` | Creates the default session grid (see below) |
| `tmux-session-overview` | TUI session/pane browser with mouse support |
| `tmux-clock` | Big-digit foreground clock, stop with `Ctrl+C` |
| `tmux-kill` | Kill a session by name (or current session if inside tmux) |

### Layout (`tmux-start`)

```
┌──────────────────────┬──────────────────────┐
│  session overview    │  tmux-clock          │
├──────────────────────┼──────────────────────┤
│  claude              │  terminal ($SHELL)   │
└──────────────────────┴──────────────────────┘
```

`tmux-start [name]` builds the grid locally. `tmux-start --ssh` opens the
`claude` and terminal panes on a remote dev box instead: it reads the host from
`~/.config/tmux-start.conf`, lists the repo folders under the configured root,
and lets you fzf-pick the one to start in. The overview and clock stay local.

```
# ~/.config/tmux-start.conf
host=dev-box   # alias from ~/.ssh/config, or user@host
root=~/code    # remote dir whose subfolders are your repos
```

Claude must be installed on the remote host for `--ssh` mode. Connections are
multiplexed (`ControlMaster`), so the listing and both panes share one session.

### Key bindings

| Binding | Action |
|---------|--------|
| `Ctrl+Space` | Prefix |
| `Ctrl+Shift+Arrow` | Move between panes (no prefix) |
| `Prefix+Arrow` | Split in arrow direction |
| `Prefix+r` | Reload config |

## Notes

- tmux scripts require bash 4+. On macOS, the setup script installs bash 5 via brew.
- Clipboard integration uses `pbcopy` on macOS and `xclip` on Linux.
- `tmux-start --ssh` requires `fzf` locally and `claude` on the remote host.
