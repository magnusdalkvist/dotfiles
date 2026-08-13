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
| `.config/sway` etc. | sway desktop, Linux only (see below) |

## sway desktop (Linux only)

An alternative to GNOME, selectable at the GDM login screen — GNOME stays
installed and nothing here touches it. Skipped entirely on macOS via
`.chezmoiignore`.

| File | Purpose |
|------|---------|
| `.config/sway/config` | Compositor: `dk` keyboard, keybinds, autostart, window rules |
| `.config/waybar/` | Top bar — transparent, no borders, pink accent |
| `.config/foot/foot.ini` | Terminal, Adwaita-dark palette |
| `.config/swaync/` | Notifications and control centre |
| `.config/swaylock/config` | Lock screen (flat dark, no screenshot blur) |
| `.config/kanshi/config` | Automatic display profiles, replaces `monitors.xml` |
| `.config/fuzzel/fuzzel.ini` | Fallback launcher and `dmenu` backend |
| `.config/environment.d/` | Wayland env vars for Electron/Qt/Firefox |
| `.config/systemd/user/sway-session.target` | Bridges sway to `graphical-session.target` |

### Packages

```sh
sudo apt install -y \
  sway swaybg swayidle swaylock autotiling \
  waybar foot fuzzel sway-notification-center \
  grim slurp swappy wl-clipboard cliphist \
  kanshi wdisplays brightnessctl playerctl \
  network-manager-gnome blueman \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  mate-polkit nwg-look wlsunset
```

Needs a Nerd Font for the bar glyphs; the configs ask for `RobotoMono Nerd Font`.

### Key bindings

| Binding | Action |
|---------|--------|
| `Super+Space` | vicinae (primary launcher) |
| `Super+D` | fuzzel (fallback launcher) |
| `Super+Return` | Terminal |
| `Super+Q` / `Alt+F4` | Close window |
| `Super+F` | Fullscreen |
| `Super+1..9` | Switch workspace (`+Shift` moves the window) |
| `Super+hjkl` / arrows | Focus (`+Shift` moves) |
| `Super+R` | Resize mode |
| `Super+L` | Lock |
| `Print` | Region screenshot into swappy (`Shift` = full, `Super` = to clipboard) |
| `Super+N` | Notification centre |
| `Super+Shift+C` | Reload config |
| `Super+Shift+E` | Exit / reboot / suspend menu |

### Design notes

- **Bar legibility.** With a fully transparent bar, a light wallpaper would
  swallow light text, so every label carries a `text-shadow`. It reads as
  nothing; remove it and the bar becomes unreadable on pale wallpapers.
- **`control-center-margin-top: 42`** in swaync clears the 34px bar plus its 4px
  margin, so notifications never overlap the clock.
- **Temperature sensor** is addressed via
  `/sys/devices/platform/coretemp.0/hwmon`, not `/sys/class/hwmon/hwmonN` —
  the `hwmonN` numbering is not stable across reboots.
- **`sway-session.target`** is not optional. sway knows nothing about systemd,
  so without it `vicinae.service` and `gnome-keyring` never start.
- **cliphist is installed but not started.** vicinae has its own clipboard
  history; running both records every copy twice.
- **Chrome** still runs under XWayland by default. Set
  `chrome://flags#ozone-platform-hint` to *Auto* for native Wayland (smoother
  scrolling, working VAAPI).

## tmux scripts

| Script | Purpose |
|--------|---------|
| `tmux-start` | Creates the default session grid (see below) |
| `tmux-session-overview` | TUI session/pane browser with mouse support |
| `tmux-clock` | Big-digit foreground clock, stop with `Ctrl+C` |
| `tmux-kill` | Kill a session by name (or current session if inside tmux) |
| `ssh-pane` | Holds a remote pane open across drops/reboots (used by `--ssh`) |

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

Each remote pane runs through `ssh-pane`, which survives the box going away: if
the connection drops or the server crashes it shows `<host> is down` and polls
every 5s, reconnecting automatically when the host returns. Claude relaunches
with `--continue`, so you land back in the conversation you left. If the host is
still down after 15 minutes it closes the tmux session rather than leaving dead
panes. Tune with `SSH_PANE_WAIT_TIMEOUT` (seconds, `0` = forever) and
`SSH_PANE_POLL` (seconds).

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
