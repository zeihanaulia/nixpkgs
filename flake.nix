{
  inputs = {
    # Define the URL for the Home Manager and Nixpkgs inputs
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs }:
    let
      # Define the list of systems for which the outputs should be provided
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-apple-darwin" ];

      # Define the username variable for use in Home Manager configurations
      username = "zeihanaulia";  

      # Define the Nix configuration directory variable, pointing to the user's Nix configuration path
      nixConfigDirectory = "~/.config/nixpkgs"; 
      
      # Function to generate system-specific Nixpkgs for each system listed in allSystems
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        # Import Nixpkgs for the given system architecture
        pkgs = import nixpkgs { inherit system; };
      });

    in {
      # Generate packages for each system configuration using the defined function
      packages = forAllSystems ({ pkgs }: {
        # Define the Home Manager configuration for the user 'zeihanaulia'
        homeConfiguration = {
          zeihanaulia = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;  # Inherit the pkgs from the imported Nixpkgs

            modules = [
              {
                # Set the state version of Home Manager (aligns with the version of Nixpkgs)
                home.stateVersion = "24.05";

                # Set the username for the Home Manager configuration
                home.username = username;

                # Conditionally set the home directory based on the operating system
                # Use '/Users/${username}' for macOS (Darwin) and '/home/${username}' for Linux
                home.homeDirectory = if pkgs.stdenv.isDarwin
                then "/Users/${username}"
                else "/home/${username}";

                # Define the packages to be installed, including specific versions of Go, Node.js, Rustup, and Python
                home.packages = with pkgs; [
                  (pkgs.go_1_23)  # Specify Go version 1.23 explicitly
                  gopls           # Go language server protocol package
                  nodejs          # Latest Node.js package available in Nixpkgs
                  python3         # Latest Python 3 package available in Nixpkgs
                  python311Packages.pip # Python pip package manager
                  rustup          # Rustup installer from Nixpkgs
                ];

                # Define an activation script to configure Rustup
                home.activation = {
                  configureRustup = ''
                    if [ -x "$HOME/.cargo/bin/rustup" ]; then
                      export PATH="$HOME/.cargo/bin:$PATH"    
                      "$HOME/.cargo/bin/rustup" toolchain install stable   
                      "$HOME/.cargo/bin/rustup" default stable            
                    fi
                  '';
                };

                # Define Zsh aliases using zsh.shellAliases
                home.shellAliases = {
                  flakeup = "nix flake lock ${nixConfigDirectory} --update-input $1";
                  nxb = "nix build ${nixConfigDirectory}/#homeConfiguration.${username}.activationPackage -o ${nixConfigDirectory}/result";
                  nxa = "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfiguration.${username}";
                };

                # Zsh Configuration
                programs.zsh = {
                  enable = true;  # Enable Zsh as the shell
                  autosuggestion.enable = true;  # Enable command autosuggestion in Zsh
                  syntaxHighlighting.enable = true;  # Enable syntax highlighting in Zsh
                  autocd = true;  # Enable autocd (change directory automatically)
                  oh-my-zsh = {
                    enable = true;  # Enable Oh My Zsh framework
                    plugins = [ "git" ];  # Use the Git plugin with Oh My Zsh
                    theme = "robbyrussell";  # Set the theme to robbyrussell
                  };
                  plugins = [{
                    name = "zsh-nix-shell";  # Plugin for integrating Nix with Zsh
                    file = "nix-shell.plugin.zsh";
                    src = pkgs.fetchFromGitHub {
                      owner = "chisui";
                      repo = "zsh-nix-shell";
                      rev = "v0.5.0";
                      sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
                    };
                  }];

                  # Correctly set environment variables for Go and Rust
                  sessionVariables = {
                    RUSTUP_HOME = "$HOME/.rustup";   # Directory for Rustup
                    CARGO_HOME = "$HOME/.cargo";     # Directory for Cargo
                    GOPATH = "$HOME/go";             # Set GOPATH environment variable to the correct path
                    CARGOBIN = "$CARGO_HOME/bin";    # Define CARGOBIN based on CARGO_HOME
                    GOBIN = "$GOPATH/bin";           # Define GOBIN based on GOPATH
                    PATH = "$CARGOBIN:$GOBIN:$HOME/.nix-profile/bin:$PATH";  # Update PATH
                  };
                };

                # Enable Home Manager programs for the user
                programs.home-manager.enable = true;
              }
            ];

          };
        };
      });
    };
}
