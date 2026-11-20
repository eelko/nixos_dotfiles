# Shell: fish as login shell (system side) plus fish/bash config, prompt,
# aliases and shell helpers (home side).
{
  # Hosts that import this get fish as eelko's login shell.
  flake.modules.nixos.shell = { pkgs, ... }: {
    programs.fish.enable = true;
    users.users.eelko.shell = pkgs.fish;
  };

  flake.modules.homeManager.shell = {
    programs.bash = {
      enable = true;
      enableCompletion = true; # bash-completion
      initExtra = ''
        export PS1='\[\e[38;5;40m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \[\e[38;5;207m\]($(git branch --show-current 2>/dev/null))\[\e[0m\] $ '
      '';
      shellAliases = {
        btw = "echo bash interpreter on nix";
        lg = "lazygit";
        nrs = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw";
        update = "nix flake update nixpkgs nixpkgs-unstable nixos-hardware && sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
        l = "eza -l --git-repos --git";
      };
    };

    programs.fish = {
      enable = true;
      shellAliases = {
        btw = "echo fish interpreter on nix";
        lg = "lazygit";
        nrs = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw";
        update = "nix flake update nixpkgs nixpkgs-unstable nixos-hardware && sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
        nclean = "sudo nix-collect-garbage";
        l = "eza -l --git-repos --git";
      };
    };
    programs.fish.functions.fish_prompt = ''
      set -l branch (git branch --show-current 2>/dev/null)

      set_color 00d700; echo -n $USER
      set_color normal; echo -n ' in '
      set_color 0087ff; echo -n (string replace -r "^$HOME" '~' -- $PWD)
      set_color normal

      if test -n "$branch"
        set_color ff5fff; echo -n " ($branch)"
        set_color normal
      end

      echo -n ' $ '
    '';

    programs.nix-your-shell = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fzf.enable = true;           # fuzzy Ctrl-R history, Ctrl-T file picker
    programs.carapace.enable = true;      # rich completions for many CLIs
  };
}
