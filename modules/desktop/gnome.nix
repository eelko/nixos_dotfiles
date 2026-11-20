# GNOME desktop with GDM.
{
  flake.modules.nixos.gnome = {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Let Electron apps (tidal-hifi, etc.) render natively under Wayland instead of XWayland.
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # A one-off GDM login as root left a stale AccountsService cache file
    # marking it as a regular (visible) user. Force it back to hidden on
    # every activation so it doesn't keep showing up in the GDM user list.
    systemd.tmpfiles.settings."10-hide-root-gdm"."/var/lib/AccountsService/users/root"."f+" = {
      argument = "[User]\nSystemAccount=true\n";
    };
  };
}
