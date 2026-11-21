# Basics every machine gets: networking, time zone, a few system tools, fonts.
{
  flake.modules.nixos.base = { pkgs, ... }: {
    # Configure network connections interactively with nmcli or nmtui.
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Amsterdam";

    environment.systemPackages = with pkgs; [
      vim                   # basic editor
      wget                  # download stuff from the internet
      git                   # essential version management
      alacritty             # basic terminal emulator
      tldr                  # Basic help
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
