{
  description = "NixOS from Scratch";

  inputs = {
    # Kernel-locked nixpkgs — T2 patches compile against this exact tree.
    # Update ONLY after testing in a VM: nix flake update nixpkgs-kernel
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/b6018f87da91d19d0ab4cf979885689b469cdd41";

    # System base: 26.05 for services, desktop, and general packages.
    # Safe to update: nix flake update nixpkgs
    nixpkgs.url = "nixpkgs/nixos-26.05";

    # Unstable channel for bleeding-edge dev tools (neovim, LSPs, language tools).
    # Safe to update: nix flake update nixpkgs-unstable
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Pinned in flake.lock — update with: nix flake update nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs-kernel, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs-kernel = import nixpkgs-kernel {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-unstable nixos-hardware; };
        modules = [
          # Injects the pinned linux_6_18 from 25.11 into the 26.05 pkgs
          # so the T2 patches still apply cleanly.
          {
            nixpkgs.overlays = [
              (final: prev: {
                linux_6_18 = pkgs-kernel.linux_6_18;
              })
            ];
          }
          ./configuration.nix
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
    };
}
