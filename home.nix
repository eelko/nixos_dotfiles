{ config, pkgs, ...}:

let 
  # dotfiles is a varable pointing to the config directory used for external configs for apps
  # managed by this home manager file
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  # create_sysmlink is a function that creates a symlink for a given path. Is used by the dotfiles structure
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Configs is a map that maps a config to a directory name in the dotfiles directory. 
  # adding a config is as simple as adding the real config to the ${dotfiles} deirectory
  # and adding the map in the config defenition
  configs = {
    qtile = "qtile";
    nvim = "nvim";
    rovi = "rovi";
    };
in
{
  home.username = "eelko";
  home.homeDirectory = "/home/eelko";
  programs.git.enable = true;
  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
      lg = "lazygit";
      nrs = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw";
      l = "eza -l --git-repos --git";
    };
    initExtra = ''
    export PS1='\[\e[38;5;40m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \[\e[38;5;207m\]($(git branch --show-current 2>/dev/null))\[\e[0m\] $ '
    '';
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos with fish";
      lg = "lazygit";
    };
  };

  programs.alacritty = {
     enable = true;
     settings = {
       window.opacity = 0.9;
     };
  };

 xdg.configFile = builtins.mapAttrs
  (name: subpath: {
  source = create_symlink "${dotfiles}/${subpath}";
  recursive = true;
 })
 configs;

# The above is a for loop running through configs and making statements like below
# xdg.configFile."nvim" = {
#  source = create_symlink "${dotfiles}/nvim";
#  recursive = true;
# };

# Programs I want installed by home manager 
 home.packages = with pkgs; [
  eza
	lazygit
	neovim
	ripgrep
	nil
	nixpkgs-fmt
	nodejs
	gcc
  rofi
 ];
}

