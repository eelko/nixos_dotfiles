{
  description = "NixOS from Scratch";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      mkProfile = { hostModules, homeModules }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = hostModules ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.eelko = { imports = homeModules; };
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        # Minimal profile: no window manager, just ly dropping you into a shell.
        nixos-btw = mkProfile {
          hostModules = [ ./configuration.nix ];
          homeModules = [ ./home.nix ];
        };

        nixos-btw-sway = mkProfile {
          hostModules = [ ./configuration.nix ./desktops/sway-desktop.nix ];
          homeModules = [ ./home.nix ./home/sway-desktop.nix ];
        };

        nixos-btw-qtile = mkProfile {
          hostModules = [ ./configuration.nix ./desktops/qtile-desktop.nix ];
          homeModules = [ ./home.nix ./home/qtile-desktop.nix ];
        };
      };
    };
}
