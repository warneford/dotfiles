#!/bin/bash
# Claude Code environment setup
# This file is sourced by Claude Code before each Bash command
# Set CLAUDE_ENV_FILE to point here in your shell config

# Add Mason bin to PATH for LSP servers (lua, python, R, etc.)
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Add other paths that Claude Code might need
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"
