#!/usr/bin/env bash
# tmux-ssh-lib.sh — shared logic for opening remote (--ssh) panes.
#
# Sourced by tmux-start (--ssh) and tmux-ssh-upgrade. Not meant to run directly.
#
# tmux_ssh_select [BASE]
#   Reads ~/.config/tmux-start.conf, lists the repo folders on the remote host,
#   and lets you fzf-pick one. On success it sets these globals:
#     HOST          the ssh host (alias or user@host)
#     REPO          absolute path of the picked folder on the remote
#     NAME          basename of REPO
#     BASE          session-name base (arg if given, else NAME sanitised)
#     REMOTE_CLAUDE command to run in the claude pane (via ssh-pane)
#     REMOTE_TERM   command to run in the terminal pane (via ssh-pane)
#   Returns non-zero (with a message on stderr) on any error or cancel.

_tmux_ssh_trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

tmux_ssh_select() {
    local base_in="${1:-}"

    if (( BASH_VERSINFO[0] < 4 )); then
        echo "tmux --ssh requires bash 4+. On macOS: brew install bash" >&2
        return 1
    fi
    command -v fzf &>/dev/null || { echo "tmux --ssh requires fzf" >&2; return 1; }

    local conf="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-start.conf"
    if [[ ! -f "$conf" ]]; then
        echo "No remote config at $conf" >&2
        echo "Create it with:" >&2
        echo "  host=your-ssh-host   # alias from ~/.ssh/config, or user@host" >&2
        echo "  root=~/code          # remote dir whose subfolders are your repos" >&2
        return 1
    fi

    HOST=""
    local root="" key val
    while IFS='=' read -r key val; do
        key="$(_tmux_ssh_trim "$key")"
        [[ -z "$key" || "$key" == \#* ]] && continue
        val="$(_tmux_ssh_trim "$val")"
        case "$key" in
            host) HOST="$val" ;;
            root) root="$val" ;;
        esac
    done < "$conf"

    [[ -z "$HOST" ]] && { echo "No 'host=' line in $conf" >&2; return 1; }
    root="${root:-~/code}"

    # Share one connection across the listing + both panes (no repeated auth).
    local ssh_ctl="$HOME/.ssh/cm-tmux-start-%r@%h:%p"
    local ssh_opts=(-o ControlMaster=auto -o "ControlPath=$ssh_ctl" -o ControlPersist=60)

    # First line is $root itself (resolved to an absolute path via pwd) so you
    # can open the whole "code" folder, not just a project inside it; the rest
    # are its subfolders. ~ and * expand on the remote; trailing slash stripped
    # for clean basenames. `cd $root` failing (missing root) yields no output.
    local repos
    mapfile -t repos < <(ssh "${ssh_opts[@]}" "$HOST" "cd $root && pwd && ls -1d $root/*/ 2>/dev/null" | sed 's#/*$##')
    if (( ${#repos[@]} == 0 )); then
        echo "No directory $root on $HOST" >&2
        return 1
    fi

    REPO=$(printf '%s\n' "${repos[@]}" | fzf --prompt="$HOST repo> " --delimiter=/ --with-nth=-1)
    [[ -z "$REPO" ]] && { echo "No selection." >&2; return 1; }

    NAME="$(basename "$REPO")"
    BASE="${base_in:-${NAME//[.:]/-}}"

    # Build the commands typed into each remote pane, wrapped in ssh-pane so a
    # dropped connection or overnight server shutdown auto-reconnects instead of
    # dumping you back to a dead local shell. %q escapes each arg for the local
    # pane shell so $SHELL and the path pass through ssh-pane to the remote
    # shell intact.
    local repo="$REPO" host="$HOST"
    _build_pane() { printf 'ssh-pane %q %q %q' "$host" "$repo" "$1"; }
    # Run claude through a login shell so the remote PATH (claude lives in
    # ~/.local/bin, added by .profile) is loaded; a bare `ssh host claude` uses a
    # non-login shell and can't find it. Login-only (-l) — NOT interactive (-i),
    # which fights the TTY for job control and kills the claude TUI on startup.
    # `claude --continue` resumes the last conversation in the repo (your restart
    # point after a reboot); `|| claude` covers the first launch when there's
    # nothing to resume yet. $SHELL is single-quoted so it expands on the remote.
    # After claude quits, `exec $SHELL -l` drops you into an interactive remote
    # shell in the SAME repo dir — so `exit` in claude leaves you on the dev box,
    # not back on your laptop. (exec at the end of -lc reuses the TTY, so this
    # shell is interactive just like the terminal pane.)
    REMOTE_CLAUDE="$(_build_pane '$SHELL -lc "claude --continue || claude; exec $SHELL -l"')"
    REMOTE_TERM="$(_build_pane 'exec $SHELL -l')"
    return 0
}
