# Nix Setup

This document provides instructions on how to set up and manage your Nix environment using Home Manager with a specific configuration.

## How to Install

### Nix

To install Nix in multi-user mode (recommended for most users), run the following command:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

This script will download and install Nix with the necessary configurations.

## Build and Activate Configuration

To build and activate the Home Manager configuration for the user, use the following commands based on your system:

### For Linux

1. **Build the configuration:**

   ```sh
   nix build ~/.config/nixpkgs/#home-zeihanaulia -o ~/.config/nixpkgs/result
   ```

2. **Activate the configuration:**

   ```sh
   ~/.config/nixpkgs/result/activate switch --flake ~/.config/nixpkgs/#homeConfiguration.zeihanaulia
   ```

### For macOS (Intel)

1. **Build the configuration:**

   ```sh
   nix build ~/.config/nixpkgs/#home-zeihanaulia -o ~/.config/nixpkgs/result
   ```

2. **Activate the configuration:**

   ```sh
   ~/.config/nixpkgs/result/activate switch --flake ~/.config/nixpkgs/#homeConfiguration.zeihanaulia
   ```

### For macOS (M1)

1. **Build the configuration:**

   ```sh
   nix build ~/.config/nixpkgs/#home-zeihanaulia -o ~/.config/nixpkgs/result
   ```

2. **Activate the configuration:**

   ```sh
   ~/.config/nixpkgs/result/activate switch --flake ~/.config/nixpkgs/#homeConfiguration.zeihanaulia
   ```

## Updating Flake Inputs

To update the lock file for specific inputs in your flake, use the `flake lock` command. For example, to update `nixpkgs-unstable`:

```sh
nix flake lock ~/.config/nixpkgs --update-input nixpkgs-unstable
```

This command updates the input for `nixpkgs-unstable` within your flake configuration.

## Using Shell Aliases

For convenience, you can use the predefined shell aliases to manage your Nix configurations:

- **Update a specific flake input:**

  ```sh
  flakeup nixpkgs-unstable
  ```

- **Build the activation package:**

  ```sh
  nxb
  ```

- **Activate the configuration:**

  ```sh
  nxa
  ```

These aliases simplify the process of managing and updating your Nix environment.

## Upgrade

- **Upgrade Nix**

```sh
nix upgrade-nix --nix-store-paths-url https://releases.nixos.org/nix/nix-2.23.3/fallback-paths.nix
```

## Reference

- [Nix Search](https://search.nixos.org/packages?channel=23.11&from=0&size=50&sort=relevance&type=packages&query=pip): A search tool to find available Nix packages and channels.
