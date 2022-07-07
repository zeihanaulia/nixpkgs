{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = { self, home-manager, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations = {
        zeihanaulia = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ({ pkgs, ... }: {
              home.stateVersion = "22.05";
              home.username = "zeihanaulia";
              home.homeDirectory = "/home/zeihanaulia/";

              home.packages = with pkgs; [
                vim
                openapi-generator-cli
                nixfmt
                home-manager
              ];

              home.shellAliases = {
                nxb =
                  "nix build ~/.config/nixpkgs/#homeConfigurations.zeihanaulia.activationPackage -o ~/.config/nixpkgs/result ";
                nxa =
                  "~/.config/nixpkgs/result/activate switch --flake ~/.config/nixpkgs/#homeConfigurations.zeihanaulia";
              };

              # programming language
              programs.go.enable = true;
              programs.go.package = pkgs.go_1_18;

              # tools
              programs.zsh.enable = true;
              programs.zsh.enableAutosuggestions = true;
              programs.zsh.enableSyntaxHighlighting = true;
              programs.zsh.autocd = true;
              programs.zsh.oh-my-zsh.enable = true;
              programs.zsh.oh-my-zsh.plugins = [ "git" ];
              programs.zsh.oh-my-zsh.theme = "robbyrussell";
              programs.zsh.plugins = [{
                name = "zsh-nix-shell";
                file = "nix-shell.plugin.zsh";
                src = pkgs.fetchFromGitHub {
                  owner = "chisui";
                  repo = "zsh-nix-shell";
                  rev = "v0.5.0";
                  sha256 =
                    "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
                };
              }];
            })
          ];
        };
      };
    };
}
