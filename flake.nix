{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, utils, ... }@inputs:
  utils.lib.eachDefaultSystem (system: 
  let 
    pkgs-unstable = import nixpkgs-unstable { inherit system; };
    overlays = [ (final: prev: { 
      go = pkgs-unstable.go;
      rustup = pkgs-unstable.rustup;
      clang = pkgs-unstable.clang;
      protobuf = pkgs-unstable.protobuf;
      llvm = pkgs-unstable.llvm;
      nodejs = pkgs-unstable.nodejs;
      yarn = pkgs-unstable.yarn;
    }) ]; 
    pkgs = import nixpkgs { inherit overlays system; };
  in
  {
    homeConfigurations = {
      zeihanaulia = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ({ pkgs, ... }: 
                let 
                  nixConfigDirectory = "~/.config/nixpkgs"; 
                  username = "zeihanaulia";
                  homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${username}";
                in {
                home.stateVersion = "22.05";
                home.username = username;
                home.homeDirectory = homeDirectory;

                home.packages = with pkgs; [
                  vim
                  openapi-generator-cli
                  nixfmt
                  home-manager
                  zsh
                  yarn
                  nodejs
                  mob
                  xclip
                  gopls
                  rustup
                  clang
                  protobuf
                  llvm
                  gnumake
                ] ++ lib.optionals pkgs.stdenv.isLinux [
                  # Add packages only for Linux
                ] ++ lib.optionals pkgs.stdenv.isDarwin [
                  # Add packages only for Darwin (MacOS)
                ];

                home.shellAliases = {
                  flakeup = 
                    # example flakeup nixpkgs-unstable
                    "nix flake lock ${nixConfigDirectory} --update-input"; 
                  nxb =
                    "nix build ${nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${nixConfigDirectory}/result ";
                  nxa =
                    "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}";
                };


                # programming language`
                programs.go.enable = true;
                programs.go.package = pkgs.go;
                programs.go.goPath = "${homeDirectory}/go";
                programs.go.goBin = "${homeDirectory}/go/bin/";

                # rust
                # RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
                home.sessionVariables = {
                  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
                  LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
                };

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

                # home manager
                programs.home-manager.enable = true;

              })
            ];
          };
    }; 
  
  });

}