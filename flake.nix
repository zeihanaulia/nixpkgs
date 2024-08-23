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
                home.stateVersion = "23.05";

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
                  rustup          # Rustup installer from Nixpkgs
                ];

                # Set up environment variables necessary for Rust development
                home.sessionVariables = {
                  RUSTUP_HOME = "$HOME/.rustup";   # Directory for Rustup
                  CARGO_HOME = "$HOME/.cargo";     # Directory for Cargo
                  PATH = "$HOME/.cargo/bin:$PATH"; # Add Cargo binaries to PATH
                };

                # Define an activation script to configure Rustup
                home.activation = {
                  configureRustup = ''
                    if [ -x "$HOME/.cargo/bin/rustup" ]; then
                      export PATH="$HOME/.cargo/bin:$PATH"    # Ensure Cargo binaries are in PATH
                      "$HOME/.cargo/bin/rustup" toolchain install stable   # Install stable Rust toolchain
                      "$HOME/.cargo/bin/rustup" default stable             # Set stable as default toolchain
                    fi
                  '';
                };

                # Define shell aliases for convenience commands related to Nix
                home.shellAliases = {
                  flakeup = ''
                    nix flake lock ${nixConfigDirectory} --update-input $1   # Update specified input in flake lock file
                  '';
                  nxb = ''
                    nix build ${nixConfigDirectory}/#homeConfigurations.${username}.activationPackage -o ${nixConfigDirectory}/result   # Build the activation package
                  '';
                  nxa = ''
                    ${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${username}   # Activate the configuration
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
