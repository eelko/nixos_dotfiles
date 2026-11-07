{ config, pkgs, ...}:

{
  home.username = "eelko";
  home.homeDirectory = "/home/eelko";
  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };
}
