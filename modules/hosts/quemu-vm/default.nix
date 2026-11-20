# QEMU VM running qtile, reachable over SSH.
# Needs --impure: imports the VM's own /etc/nixos/hardware-configuration.nix.
{ inputs, config, ... }:

{
  flake.nixosConfigurations.quemu_vm = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with config.flake.modules.nixos; [
      nix
      base
      eelko
      qtile
      browsers
      ssh-server
      quemu-vm
    ];
  };

  flake.modules.nixos.quemu-vm = { pkgs, ... }: {
    imports = [ /etc/nixos/hardware-configuration.nix ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    services.qemuGuest.enable = true;

    networking.hostName = "nixos-btw";

    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xrandr}/bin/xrandr --output Virtual-1 --mode 1920x1200
    '';

    users.users.eelko.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgi4qYwTyT96lXkgTc/KOqxWy4cxKTU6DVDUxducCTN eelko@umbp"
    ];

    # The VM keeps bash as login shell (no `shell` feature), but home-manager
    # configures fish for eelko, so fish has to be available system-wide.
    programs.fish.enable = true;

    system.stateVersion = "25.05"; #Don't change this number
  };
}
