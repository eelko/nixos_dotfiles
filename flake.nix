{
  description = "Dendritic flake setup Eelko";

  inputs = {
    # Kernel-locked nixpkgs — T2 patches compile against this exact tree.
    # Update ONLY after testing first: nix flake update nixpkgs-kernel
    # Used only by modules/hardware/apple-t2.nix.
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/b6018f87da91d19d0ab4cf979885689b469cdd41";
    # Also pinned in flake.lock — update with: nix flake update nixos-hardware
    # This is the T2 patch code that will be applied to the kernel.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # System base: 26.05 for services, desktop, and general packages.
    # Safe to update: nix flake update nixpkgs
    nixpkgs.url = "nixpkgs/nixos-26.05";

    # Unstable channel for bleeding-edge dev tools (neovim, LSPs, language tools).
    # Exposed to all modules as pkgs.unstable (see modules/nix.nix).
    # Safe to update: nix flake update nixpkgs-unstable
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dendritic pattern: every .nix file under ./modules is a flake-parts module,
    # auto-imported by import-tree (paths containing "/_" are skipped).
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
  };

  # Features live in modules/<feature>.nix, hosts in modules/hosts/<host>/.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
