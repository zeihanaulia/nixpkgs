#!/usr/bin/env bash
set -euo pipefail

echo "🛠️ Installing Nix (if not already)..."

if ! command -v nix &>/dev/null; then
  echo "📦 Installing Nix via Determinate Systems installer..."
  curl -L https://install.determinate.systems/nix | bash
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
else
  echo "✅ Nix already installed."
fi

if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

echo "🔧 Enabling flakes..."
mkdir -p ~/.config/nix
grep -q 'experimental-features' ~/.config/nix/nix.conf || echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

echo "📥 Cloning flake config..."
if [ ! -d "$HOME/nixpkgs" ]; then
  git clone https://github.com/zeihanaulia/nixpkgs.git "$HOME/nixpkgs"
fi

cd "$HOME/nixpkgs"
echo "🚀 Activating Home Manager config..."
if ! command -v home-manager &>/dev/null; then
  nix profile install nixpkgs#home-manager
fi

home-manager switch --flake .#$(whoami)
echo "🎉 Done!"
