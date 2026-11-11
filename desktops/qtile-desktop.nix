# qtile (X11 window manager)

{ pkgs, ... }:

{
  services.displayManager.ly.enable = true;

  environment.systemPackages = with pkgs; [
    rofi                   # application launcher
    alacritty              # basic terminal emulator
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      ${pkgs.xrandr}/bin/xrandr --output Virtual-1 --mode 1920x1200
    '';
  };
}
