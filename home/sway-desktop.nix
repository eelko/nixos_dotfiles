{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    rofi = "rofi";
    sway = "sway";
    waybar = "waybar";
  };
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.9;
    };
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;
}
