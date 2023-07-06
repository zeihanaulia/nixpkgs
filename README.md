# Nix Setup

## Install nix

**Welcome**!
It's great to see that you're interested in [Nix].
In this [quick start][start], we'll get Nix installed on your system and provide you with a small taste of Nix's feature set by accomplishing some practical things, such as [creating a development environment][dev] and [building a package][build] using Nix.

We recommend installing Nix using the [Determinate Nix installer][nix-installer], a tool from [Determinate Systems][detsys] that tailors the installation process to your system.
The installer supports these platforms:

Platform | Multi user? | `root` only
:--------|:------------|:-----------
Linux on 64-bit ARM and 64-bit AMD/Intel (no [SELinux]) | ✅ (via [systemd]) | ✅
macOS on 64-bit ARM and 64-bit AMD/Intel | ✅ |
[Valve Steam Deck][steamdeck] (SteamOS) | ✅ |
[Windows Subsystem for Linux][wsl] (WSL) on 64-bit ARM and 64-bit AMD/Intel | ✅ (via [systemd]) | ✅
[Podman] Linux containers | ✅ (via [systemd]) | ✅
[Docker] containers | | ✅

To run the installer:

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

If you have concerns about the "curl to Bash" approach you have two options:

1. You can download a binary for the most recent version of the Determinate Nix Installer directly from the [releases] page and run it.
1. You can examine the installation script [here][script] then download and run it:

    ```shell
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix > nix-installer.sh
    chmod +x nix-installer.sh
    ./nix-installer.sh install
    ```

<Admonition info title="Why aren't we using the official Nix installation script here?" id="why-nix-installer" client:load>
We believe that the Determinate Nix Installer provides a smoother experience for people who are new to Nix than the [official Nix installation script][official].
Unlike many tools, Nix needs to make several changes to your system in order to work properly, such as creating a new `/nix` directory, configuring your shell profile, and creating several new system users and groups.

The Determinate Nix Installer improves on the official Nix installation script by enabling you to undo, with a single command, all of the system changes introduced by the installation process.
It also installs Nix with [Nix flakes][flakes] enabled while the official installer requires you to enable flakes manually.

See the [Uninstalling Nix][uninstall] guide if you need to uninstall Nix or the [Determinate Nix Installer][nix-installer] concept doc if you'd like more background.
</Admonition>

Validate the displayed plan and approve it to begin the installation process.
Once the installer has finished, you should see `Nix was installed successfully!` in your terminal.

Open a new terminal session and the `nix` executable should be in your `$PATH`.
To verify that:

```bash
nix --version
```

This should print the version information for Nix.

:rocket: **Success**!
You now have Nix installed and ready to go on your system.

<Admonition info title="How to contribute to Zero to Nix" id="contributing" client:load>
If you're interested in contributing to Zero to Nix, see the [manual][contributing] in the project [repo] for some suggestions.
</Admonition>

Reference: <https://zero-to-nix.com/start/install>

## How to use


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

