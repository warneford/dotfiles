#!/bin/bash
# Setup script for reverse SSH tunnel (remote nvim → local browser)
# This enables <leader>qp in nvim to open browser on your local machine
#
# Run this script on the REMOTE HOST (where Docker runs), not the container

set -e

echo "=== Reverse SSH Tunnel Setup ==="
echo "This enables remote nvim to trigger commands on your local machine"
echo ""

# Prompt for configuration
read -p "Local machine username (your Mac/laptop): " LOCAL_USER
read -p "SSH port for reverse tunnel [9018]: " TUNNEL_PORT
TUNNEL_PORT=${TUNNEL_PORT:-9018}

# Check for existing SSH key
if [[ -f ~/.ssh/id_ed25519 ]]; then
    echo ""
    echo "Found existing SSH key: ~/.ssh/id_ed25519"
    read -p "Use this key? [Y/n]: " USE_EXISTING
    if [[ "${USE_EXISTING,,}" == "n" ]]; then
        echo "Please manually create a new key and re-run this script"
        exit 1
    fi
else
    echo ""
    echo "No SSH key found. Generating new ed25519 key..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -C "$(whoami)@$(hostname)"
fi

PUBLIC_KEY=$(cat ~/.ssh/id_ed25519.pub)

# Add own key to authorized_keys (for container → host SSH)
if ! grep -q "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys 2>/dev/null; then
    echo ""
    echo "Adding public key to this host's authorized_keys..."
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    echo "Done."
else
    echo ""
    echo "Public key already in this host's authorized_keys"
fi

echo ""
echo "=== Manual steps required on your LOCAL machine ==="
echo ""
echo "1. Enable Remote Login (SSH server):"
echo "   macOS: System Settings → General → Sharing → Remote Login"
echo ""
echo "2. Add this public key to your local ~/.ssh/authorized_keys:"
echo ""
echo "   $PUBLIC_KEY"
echo ""
echo "3. Add RemoteForward to your SSH config (~/.ssh/config):"
echo ""
echo "   Host your-remote-host"
echo "       RemoteForward $TUNNEL_PORT localhost:22"
echo ""
echo "4. Reconnect to your remote host for the tunnel to take effect"
echo ""
echo "=== Setup complete ==="
