{
  description = "Dev environment for my NixOS-WSL setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
    let
      username = "zeihanaulia";
      systems = [ "x86_64-linux" "aarch64-darwin" ]; # atau pake flake-utils.defaultSystems
    in
    flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        homeConfig = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/${username}.nix
            ./modules/bash.nix
            ./modules/zsh.nix
          ];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ git vim zsh wget ];
        };

        homeConfigurations.${username} = homeConfig;

        packages.activate = homeConfig.activationPackage;

        apps.activate = {
          type = "app";
          program = "${homeConfig.activationPackage}/activate";
        };
      }
    );



}
