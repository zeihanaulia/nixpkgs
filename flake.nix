{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      username = "zeihanaulia";
      system = "aarch64-darwin";  # Mac M1
      pkgs = import nixpkgs { inherit system; };
    in
    {
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {

          # FIX PALING PENTING
          pkgs = pkgs;

          # FIX PALING PENTING nomor 2:
          extraSpecialArgs = {
            inherit pkgs username system;
          };

          modules = [
            {
              home.stateVersion = "24.05";

              home.username = username;
              home.homeDirectory = "/Users/${username}";
              home.enableNixpkgsReleaseCheck = false;

              home.packages = with pkgs; [
                go_1_24
                gopls
                gotests
                gomodifytags
                impl
                delve
                mariadb.client
                nodejs_24
                pnpm
                python3
                python311Packages.pip
                python311Packages.uv
                rustup
                gh
                jdk17
                python311Packages.jupyterlab
                deno
                poetry
              ];

              home.shellAliases = {
                flakeup = "nix flake lock . --update-input $1";
                nxa = ''home-manager switch --flake .#${username}'';
              };

              home.sessionVariables = {
                GOPATH = "$HOME/go";
                GOBIN = "$HOME/go/bin";
                RUSTUP_HOME = "$HOME/.rustup";
                CARGO_HOME = "$HOME/.cargo";
                CARGOBIN = "$CARGO_HOME/bin";
                NPM_CONFIG_PREFIX = "$HOME/.npm-global";
                PATH = "$HOME/.npm-global/bin:$CARGOBIN:$GOBIN:$HOME/.nix-profile/bin:$PATH";
              };

              programs.zsh = {
                enable = true;
                autosuggestion.enable = true;
                syntaxHighlighting.enable = true;
                autocd = true;
                oh-my-zsh = {
                  enable = true;
                  plugins = [ "git" ];
                  theme = "robbyrussell";
                };
                plugins = [{
                  name = "zsh-nix-shell";
                  file = "nix-shell.plugin.zsh";
                  src = pkgs.fetchFromGitHub {
                    owner = "chisui";
                    repo = "zsh-nix-shell";
                    rev = "v0.5.0";
                    sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
                  };
                }];
              };

              programs.home-manager.enable = true;
            }
          ];
        };
      };
    };
}
