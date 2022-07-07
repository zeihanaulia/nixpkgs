{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = {self, home-manager, nixpkgs, ...}@inputs:
      let 
	system = "x86_64-linux";
	pkgs = nixpkgs.legacyPackages.${system}; 
      in 
	{
             homeConfigurations = {
                 zeihanaulia = home-manager.lib.homeManagerConfiguration {
                      inherit pkgs;
		      modules = [
		          ({pkgs, ...}:{
                              home.stateVersion = "22.05";
                              home.username = "zeihanaulia";
			      home.homeDirectory = "/home/zeihanaulia/";

			      home.packages = with pkgs;[
                                  vim
				  openapi-generator-cli
                              ];
			      
			      # programming language
                              programs.go.enable = true;
			      programs.go.package = pkgs.go_1_18;
			      
			      # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			      
			      # tools
			      programs.zsh.enable = true;
			      programs.zsh.enableAutosuggestions = true;
			      programs.zsh.enableSyntaxHighlighting = true;
			      programs.zsh.autocd = true;
			      programs.zsh.oh-my-zsh.enable = true;
			      programs.zsh.oh-my-zsh.plugins = ["git"];
			      programs.zsh.oh-my-zsh.theme = "robbyrussell";
                          })	
		      ];
                 };
             };
        };
}
