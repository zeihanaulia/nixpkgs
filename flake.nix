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
                              ];

                              programs.go.enable = true;
			      programs.go.package = pkgs.go_1_18;
                          })	
		      ];
                 };
             };
        };
}
