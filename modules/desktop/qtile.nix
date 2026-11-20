# Qtile window manager on X11 with the ly display manager.
# The qtile config itself is symlinked from config/qtile (modules/dotfiles.nix).
{
  flake.modules.nixos.qtile = { pkgs, ... }: {
    services.xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;
      windowManager.qtile.enable = true;
    };
    services.displayManager.ly.enable = true;

    environment.systemPackages = with pkgs; [
      rofi                  # application launcher for qtile
    ];
  };
}
