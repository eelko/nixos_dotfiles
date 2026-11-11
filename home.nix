# Shared across every profile (sway / qtile / shell): shell setup, git,
# general + programming tools, and the nvim/tmux dotfiles that have nothing
# to do with which window manager (if any) is in use.

{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
    tmux = "tmux";
  };
in
{
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

  programs.bash = {
    enable = true;
    enableCompletion = true; # bash-completion
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
      export PS1='\[\e[38;5;40m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \[\e[38;5;207m\]($(git branch --show-current 2>/dev/null))\[\e[0m\] $ '
    '';
    shellAliases = {
      btw = "Eelko's home manager nix setup with bash";
      lg = "lazygit";
      nrs = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw";
      nrs-sway = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw-sway";
      nrs-qtile = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw-qtile";
      update = "sudo nix flake update && sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw";
      l = "eza -l --git-repos --git";
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos with fish";
      lg = "lazygit";
      nrs = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw";
      nrs-sway = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw-sway";
      nrs-qtile = "sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw-qtile";
      update = "sudo nix flake update && sudo nixos-rebuild --impure switch --flake ~/nixos-dotfiles#nixos-btw";
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

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  # Programs I want installed by home manager
  home.packages = with pkgs; [
    # General tools
    eza                   # modern ls replacement (used by the l alias)
    lazygit               # terminal UI for git
    neovim                # text editor
    ripgrep               # fast grep, used by Telescope live grep
    bat                   # nice cat
    tmux                  # terminal multiplexer
    claude-code           # Claude Code CLI

    # Programming
    gcc                   # C compiler, also used to build treesitter parsers
    tree-sitter           # CLI that nvim-treesitter uses to compile parsers
    clang-tools           # clangd language server and clang-format formatter for C and C++
    lua-language-server   # Lua language server (lua_ls), also formats Lua
    nil                   # Nix language server
    nixpkgs-fmt           # Nix formatter
    taplo                 # TOML language server and formatter
    yaml-language-server  # YAML language server (yamlls), also formats YAML
    pyright               # Python language server: types, completion, navigation
    ruff                  # Python linter and formatter (also runs as a language server)
    bash-language-server  # Bash language server (bashls)
    shellcheck            # shell script linter, used by bashls for diagnostics
    shfmt                 # shell script formatter
    # nodejs                # JavaScript runtime
    # rustc                 # Rust compiler
    # cargo                 # Rust build tool and package manager
    # rust-analyzer         # Rust language server
    # rustfmt               # Rust formatter

  ];
}
