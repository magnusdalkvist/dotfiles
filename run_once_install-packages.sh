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

if ! command -v zoxide &>/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
