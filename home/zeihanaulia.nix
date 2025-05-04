{ config, pkgs, ... }: {
 
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  home.packages = with pkgs; [
    git
    neofetch
    bat
    zoxide
    wget
    home-manager
    vscode
  ];

  home.stateVersion = "24.05";
}
