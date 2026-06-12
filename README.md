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
