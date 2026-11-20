# Apple T2 support for this MacBook.
#
# The T2 patches from nixos-hardware only compile against the linux_6_18 from
# nixpkgs 25.11, so that kernel is taken from the pinned `nixpkgs-kernel`
# flake input and injected into the 26.05 package set via an overlay.
{ inputs, ... }:

{
  imports = [ inputs.nixos-hardware.nixosModules.apple-t2 ];

  nixpkgs.overlays = [
    (final: prev: {
      # prev.stdenv.hostPlatform.system (not pkgs.system) avoids infinite recursion.
      linux_6_18 = inputs.nixpkgs-kernel.legacyPackages.${prev.stdenv.hostPlatform.system}.linux_6_18;
    })
  ];
}
