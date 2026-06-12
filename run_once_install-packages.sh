#!/usr/bin/env bash
# Install system packages needed for the setup.
install_pkg() {
    local pkg="$1"
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y "$pkg"
    elif command -v brew &>/dev/null; then
        brew install "$pkg"
    else
        echo "No supported package manager found, install $pkg manually."
    fi
}

command -v tmux &>/dev/null || install_pkg tmux
command -v fzf &>/dev/null || install_pkg fzf
command -v nvim &>/dev/null || install_pkg nvim

# macOS ships bash 3.2; the tmux scripts require bash 4+
if [[ "$(uname)" == "Darwin" ]] && (( BASH_VERSINFO[0] < 4 )); then
    install_pkg bash
fi

if ! command -v zoxide &>/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
