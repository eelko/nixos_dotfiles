# Sway (Wayland window manager)

{ pkgs, ... }:

{
  services.displayManager.ly.enable = true;

  environment.systemPackages = with pkgs; [
    rofi                   # application launcher
    alacritty              # basic terminal emulator
    adwaita-icon-theme     # provides the Adwaita cursor theme (see sessionVariables below)
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment.sessionVariables = {
    # virtio-gpu's hardware cursor plane renders garbled/offset under wlroots
    # in this VM — composite the cursor in software instead.
    WLR_NO_HARDWARE_CURSORS = "1";
    # Xwayland apps (e.g. Firefox) otherwise fall back to their own default
    # cursor theme/size, producing a visible second pointer alongside the
    # native Wayland one — pin both to the same theme.
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      waybar
      swaybg
      swaylock
      grim
      slurp
      wl-clipboard
    ];
  };
}
