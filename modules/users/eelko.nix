# The eelko user: system account, home-manager wiring and the home features
# this user gets. The home features themselves live in their own files.
{ inputs, config, ... }:

let
  homeModules = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.eelko = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    # Don't forget to set a password with ‘passwd’.
    users.users.eelko = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.eelko.imports = with homeModules; [
        eelko
        shell
        dotfiles
        apps
        dev-tools
      ];
    };
  };

  flake.modules.homeManager.eelko = {
    home.username = "eelko";
    home.homeDirectory = "/home/eelko";
    home.stateVersion = "25.05"; # dont change this for update, compatibility thing

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "eelko";
          email = "6917935+eelko@users.noreply.github.com";
        };
      };
    };
  };
}
