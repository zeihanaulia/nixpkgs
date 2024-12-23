{
  inputs = {
    # Specify the source for the Home Manager configuration
    # This fetches Home Manager from its GitHub repository
    home-manager.url = "github:nix-community/home-manager";
    # Make Home Manager follow the same Nixpkgs version
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Specify the source for Nixpkgs, the main package collection
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs }:
    let
      # Define the list of supported systems and architectures
      # This ensures configuration is generated for each specified system
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-apple-darwin" ];

      # Specify the username for Home Manager configurations
      # Used for setting up the home directory and other user-specific settings
      username = "zeihanaulia";

      # Specify the Nix configuration directory for the user
      # Points to the path where Home Manager configuration files are stored
      nixConfigDirectory = "~/.config/nixpkgs"; 
      
      # Function to generate Nixpkgs configurations for each system in `allSystems`
      # `genAttrs` creates a set of attributes based on the provided list of systems
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        # Import Nixpkgs for the given system architecture
        pkgs = import nixpkgs { inherit system; };
      });

    in {
      # Generate packages for each system configuration
      packages = forAllSystems ({ pkgs }: {
        # Define the Home Manager configuration for the user
        homeConfiguration = {
          zeihanaulia = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;  # Import `pkgs` from the Nixpkgs configurations

            modules = [
              {
                # Specify the Home Manager state version
                # This version must align with the Nixpkgs version used
                home.stateVersion = "24.05";

                # Define the username for Home Manager
                home.username = username;

                # Set the home directory conditionally based on the operating system
                # For macOS, use `/Users/username`
                # For Linux, use `/home/username`
                home.homeDirectory = if pkgs.stdenv.isDarwin
                then "/Users/${username}"
                else "/home/${username}";

                # Specify the list of packages to be installed
                home.packages = with pkgs; [
                  (pkgs.go_1_23)  # Install Go version 1.23
                  gopls           # Language server for Go
                  gotests         # Tool for managing tests in Go
                  gomodifytags    # Tool for modifying struct tags in Go
                  impl            # Tool to generate method stubs in Go
                  delve           # Debugger for Go
                  mysql-client    # MySQL client tools
                  nodejs          # Latest Node.js version
                  python3         # Latest Python 3 version
                  python311Packages.pip # Python package manager (pip)
                  rustup          # Rustup installer for managing Rust versions
                  gcc             # GCC compiler
                  glibc           # GNU C Library
                ];

                # Define an activation script for configuring Rustup
                home.activation = {
                  configureRustup = ''
                    if [ -x "$HOME/.cargo/bin/rustup" ]; then
                      export PATH="$HOME/.cargo/bin:$PATH"    
                      "$HOME/.cargo/bin/rustup" toolchain install stable   
                      "$HOME/.cargo/bin/rustup" default stable            
                    fi
                  '';
                };

                # Define custom Zsh aliases
                home.shellAliases = {
                  flakeup = "nix flake lock ${nixConfigDirectory} --update-input $1"; # Update flake inputs
                  nxb = "nix build ${nixConfigDirectory}/#homeConfiguration.${username}.activationPackage -o ${nixConfigDirectory}/result"; # Build Home Manager configuration
                  nxa = "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfiguration.${username}"; # Activate Home Manager configuration
                };

                # Define session variables for Go, Rust, and PATH
                home.sessionVariables = {
                  RUSTUP_HOME = "$HOME/.rustup";  # Directory for Rustup installation
                  CARGO_HOME = "$HOME/.cargo";  # Directory for Cargo binaries
                  GOPATH = "$HOME/go";  # Go workspace directory
                  GOBIN = "$HOME/go/bin";  # Directory for Go binaries
                  PATH = let
                    customPaths = [
                      "/home/zeihanaulia/go/bin" # Path for Go binaries
                      "$HOME/.cargo/bin"        # Path for Rust Cargo binaries
                      "$HOME/.nix-profile/bin"  # Path for Nix profile binaries
                      "${pkgs.nodejs}/bin"      # Path for Node.js binaries
                    ];
                    cleanPaths = builtins.concatStringsSep ":" (builtins.filter (path: path != "") customPaths);
                  in
                    "${cleanPaths}:$PATH";  # Combine all paths into a single PATH variable
                };

                # Global configuration for Neovim
                programs.neovim = {
                  enable = true;        # Enable Neovim
                  defaultEditor = true; # Set Neovim as the default editor
                  viAlias = true;       # Add an alias for `vi`
                  vimAlias = true;      # Add an alias for `vim`
                };

                # Configuration for Zsh shell
                programs.zsh = {
                  enable = true;  # Enable Zsh shell
                  autosuggestion.enable = true;  # Enable command autosuggestions
                  syntaxHighlighting.enable = true;  # Enable syntax highlighting
                  autocd = true;  # Enable automatic directory switching
                  
                  oh-my-zsh = {
                    enable = true;  # Enable the Oh My Zsh framework
                    plugins = [ "git" ];  # Add the Git plugin
                    theme = "robbyrussell";  # Set the theme to `robbyrussell`
                  };
                  
                  plugins = [ {
                    name = "zsh-nix-shell";  # Plugin for integrating Nix with Zsh
                    file = "nix-shell.plugin.zsh";
                    src = pkgs.fetchFromGitHub {
                      owner = "chisui";
                      repo = "zsh-nix-shell";
                      rev = "v0.5.0";
                      sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
                    };
                  } ];

                  # Additional initialization for Zsh
                  initExtra = ''
                    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
                      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                    fi
                  '';
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
