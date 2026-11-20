{
  description = "NixOS from Scratch";

  inputs = {
    # Kernel-locked nixpkgs — T2 patches compile against this exact tree.
    # Update ONLY after testing first: nix flake update nixpkgs-kernel
    # Used only by hosts/macbookpro16_2/t2.nix.
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/b6018f87da91d19d0ab4cf979885689b469cdd41";
    # Also pinned in flake.lock — update with: nix flake update nixos-hardware
    # This is the T2 patch code that will be applied to the kernel.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # System base: 26.05 for services, desktop, and general packages.
    # Safe to update: nix flake update nixpkgs
    nixpkgs.url = "nixpkgs/nixos-26.05";

    # Unstable channel for bleeding-edge dev tools (neovim, LSPs, language tools).
    # Safe to update: nix flake update nixpkgs-unstable
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Generic host builder: everything host-specific lives in hosts/<hostDir>/.
      # Modules get `inputs` via specialArgs, so a host can pull in any flake
      # input it needs (e.g. nixos-hardware, nixpkgs-kernel) on its own.
      mkHost = hostDir: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs-unstable; };
        modules = [
          ./hosts/${hostDir}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.eelko = import ./home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit pkgs-unstable; };
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        # MacBook Pro 16,2 (T2). Name kept as nixos-btw for the nrs/update aliases.
        nixos-btw = mkHost "macbookpro16_2";
        # QEMU VM (needs --impure: imports /etc/nixos/hardware-configuration.nix).
        quemu_vm = mkHost "quemu_vm";
      };
    };
}
