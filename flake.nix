{
  description = "NixOS from Scratch";

  inputs = {
    # Kernel-locked nixpkgs — T2 patches compile against this exact tree.
    # Update ONLY after testing in a VM: nix flake update nixpkgs-kernel
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/b6018f87da91d19d0ab4cf979885689b469cdd41";

    # Regular package set for user-space and system packages.
    # Safe to update freely: nix flake update nixpkgs-new
    nixpkgs-new.url = "nixpkgs/nixos-26.05";

    # Pinned in flake.lock — update with: nix flake update nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-kernel";
    };
  };

  outputs = { self, nixpkgs-kernel, nixpkgs-new, nixos-hardware, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs-new = import nixpkgs-new {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos-btw = nixpkgs-kernel.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-new nixos-hardware; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.eelko = import ./home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit pkgs-new; };
            };
          }
        ];
      };
    };
}
