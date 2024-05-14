# Nix Setup

## How to Install

### Nix

```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Build

```
nix build github:zeihanaulia/nixpkgs#homeConfigurations.x86_64-linux.zeihanaulia.activationPackage
```

### Update lock for specific inputs

```
# example
flake nixpkgs-unstable
```

### nix build

```bash
# ${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}
# first using nix build 
// https://github.com/numtide/flake-utils/blob/main/allSystems.nix

# for linux
## Build
nix build ~/.config/nixpkgs/#homeConfigurations.x86_64-linux.zeihanaulia.activationPackage -o ~/.config/nixpkgs/result 
## Activated
~/.config/nixpkgs/result/activate switch --flake ~/.config/nixpkgs/#homeConfigurations.x86_64-linux.zeihanaulia

## for darwin (macos intel)
nix build ~/.config/nixpkgs/#homeConfigurations.x86_64-darwin.zeihanaulia.activationPackage -o ~/.config/nixpkgs/result

## for darwin (macos M1)
nix build ~/.config/nixpkgs/#homeConfigurations.aarch64-darwin.zeihanaulia.activationPackage -o ~/.config/nixpkgs/result

## Then you can use alias 
nxa 
```

## Reference

- [Nix Search](https://search.nixos.org/packages?channel=23.11&from=0&size=50&sort=relevance&type=packages&query=pip)