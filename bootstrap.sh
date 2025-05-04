#!/usr/bin/env bash
set -euo pipefail

echo "🛠️ Installing Nix (if not already)..."

if ! command -v nix &>/dev/null; then
  echo "📦 Installing Nix..."
  curl -L https://nixos.org/nix/install | sh
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
else
  echo "✅ Nix already installed."
fi

# Ensure nix profile is loaded
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

echo "🔧 Enabling flakes..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

echo "📥 Cloning flake config from master..."
if [ ! -d "$HOME/nixpkgs" ]; then
  git clone --branch master https://github.com/zeihanaulia/nixpkgs.git "$HOME/nixpkgs"
else
  echo "📁 Folder ~/nixpkgs already exists. Skipping clone."
fi

cd "$HOME/nixpkgs"

echo "🚀 Activating via home-manager..."
if ! command -v home-manager &>/dev/null; then
  nix profile install nixpkgs#home-manager
fi

home-manager switch --flake .#$(whoami)

echo "🎉 Done!"
