# Apple T2 Macs (MacBook Pro 16,2): T2 kernel + patches, Wi-Fi firmware,
# keyboard, suspend workaround and Touch Bar.
#
# The T2 patches from nixos-hardware only compile against the linux_6_18 from
# nixpkgs 25.11, so that kernel is taken from the pinned `nixpkgs-kernel`
# flake input and injected into the 26.05 package set via an overlay.
{ inputs, ... }:

{
  flake.modules.nixos.apple-t2 = { pkgs, ... }: {
    imports = [ inputs.nixos-hardware.nixosModules.apple-t2 ];

    nixpkgs.overlays = [
      (final: prev: {
        # prev.stdenv.hostPlatform.system (not pkgs.system) avoids infinite recursion.
        linux_6_18 = inputs.nixpkgs-kernel.legacyPackages.${prev.stdenv.hostPlatform.system}.linux_6_18;
      })
    ];

    # MacBook T2 firmware load (needs --impure: reads from /etc/nixos).
    hardware.firmware = [
      (pkgs.stdenvNoCC.mkDerivation (final: {
        name = "brcm-firmware";
        src = /etc/nixos/firmware/brcm;
        installPhase = ''
          mkdir -p $out/lib/firmware/brcm
          cp ${final.src}/* "$out/lib/firmware/brcm"
        '';
      }))
    ];

    # Swap the Cmd and Option/Alt keys on the internal Apple keyboard.
    boot.kernelParams = [ "hid_apple.swap_opt_cmd=1" ];

    # T2 suspend workaround (t2linux wiki): the T2 resets its USB devices on
    # wake, which leaves the Touch Bar dead. Unload apple-bce before sleep and
    # reload it after resume. Wi-Fi (brcmfmac) is deliberately left alone: it
    # survives suspend by itself, and reloading it right after resume fails
    # with "Unable to change power state from D3cold to D0".
    systemd.services.t2-suspend-fix = {
      description = "Unload/reload apple-bce around suspend (T2 Touch Bar fix)";
      before = [ "sleep.target" ];
      wantedBy = [ "sleep.target" ];
      unitConfig.StopWhenUnneeded = true;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.kmod}/bin/rmmod -f apple-bce";
        ExecStop = [
          "${pkgs.kmod}/bin/modprobe apple-bce"
          # The Touch Bar disappears with apple-bce; restart tiny-dfr so it
          # re-attaches to it. "-" = don't fail the unit if this fails.
          # "-${pkgs.systemd}/bin/systemctl restart tiny-dfr.service"
        ];
      };
    };

    # Customizable Touch Bar via tiny-dfr (draws the bar through appletbdrm).
    # Settings are merged over the package defaults, see
    # ${pkgs.tiny-dfr}/share/tiny-dfr/config.toml for all keys and examples.
    # Buttons can only send key codes; to run a command, send e.g. F13
    # and bind that key in qtile.
    hardware.apple.touchBar = {
      enable = true;
      settings = {
        MediaLayerDefault = true;   # media keys by default, hold Fn for F1–F12
        EnablePixelShift = true;    # slowly shift contents to spare the OLED
        ShowButtonOutlines = false;
      };
    };
  };
}
