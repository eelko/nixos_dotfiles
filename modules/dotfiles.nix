# Out-of-store symlinks from ~/.config/<app> to ~/nixos-dotfiles/config/<app>,
# so app configs can be edited live without a rebuild.
{
  flake.modules.homeManager.dotfiles = { config, pkgs, ... }:
    let
      # dotfiles is a variable pointing to the config directory used for external configs for apps
      # managed by this home manager file
      dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
      # create_symlink is a function that creates a symlink for a given path. Is used by the dotfiles structure
      create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
      # configs is a map that maps a config to a directory name in the dotfiles directory.
      # adding a config is as simple as adding the real config to the ${dotfiles} directory
      # and adding the map in the config definition
      configs = {
        qtile = "qtile";
        nvim = "nvim";
        rofi = "rofi";
        tmux = "tmux";
        alacritty = "alacritty";
      };
    in
    {
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

      # Check out any git submodules under ${dotfiles} that aren't initialized yet
      # (e.g. after a fresh clone without --recurse-submodules). Only touches
      # uninitialized submodules, so branches/local edits in existing ones are left alone.
      home.activation.initDotfilesSubmodules = config.lib.dag.entryBefore [ "linkGeneration" ] ''
        repo="${config.home.homeDirectory}/nixos-dotfiles"
        git="${pkgs.git}/bin/git"
        if $git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
          missing=$($git -C "$repo" submodule status | ${pkgs.gawk}/bin/awk '/^-/ {print $2}')
          if [ -n "$missing" ]; then
            verboseEcho "Initializing dotfiles submodules: $missing"
            if ! run env PATH="${pkgs.openssh}/bin:$PATH" $git -C "$repo" submodule update --init --recursive -- $missing; then
              warnEcho "Could not initialize dotfiles submodules ($missing); run 'git submodule update --init' in $repo"
            fi
          fi
        fi
      '';
    };
}
