# Nix itself: flakes, nh, unfree packages and the pkgs.unstable package set.
{ inputs, ... }:

{
  flake.modules.nixos.nix = {
    # Allow unfree packages (e.g. tidal-hifi's bundled castlabs/Widevine Electron build).
    nixpkgs.config.allowUnfree = true;

    # Unstable channel as pkgs.unstable, for bleeding-edge dev tools.
    # home-manager uses useGlobalPkgs, so home modules see it too.
    nixpkgs.overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      })
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 14d --keep 5";
      };
    };
  };
}
