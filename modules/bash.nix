{ config, pkgs, ... }: {
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ -z "$ZSH_VERSION" && -x "${pkgs.zsh}/bin/zsh" ]]; then
        exec ${pkgs.zsh}/bin/zsh
      fi
    '';
  };
}
