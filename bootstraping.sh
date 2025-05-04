#!/usr/bin/env bash
set -e

echo "🛠️ Installing Nix..."

# Install Nix
if ! command -v nix &> /dev/null; then
  curl -L https://nixos.org/nix/install | sh
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Clone flake config
if [ ! -d "$HOME/nixpkgs" ]; then
  echo "📥 Cloning your flake config..."
  git clone https://github.com/zeihanaulia/nixpkgs.git "$HOME/nixpkgs"
fi

cd "$HOME/nixpkgs"

echo "🚀 Activating Home Manager config..."
nix run .#activate --impure
