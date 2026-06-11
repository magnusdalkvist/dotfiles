#!/usr/bin/env bash
# Install oh-my-posh to ~/.local/bin if not already present.
if ! command -v oh-my-posh &>/dev/null; then
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi
