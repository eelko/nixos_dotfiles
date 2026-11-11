{ config, pkgs, pkgs-unstable, ... }:

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
    rovi = "rovi";
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
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
      update = "nix flake update nixpkgs nixpkgs-unstable nixos-hardware && sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
      l = "eza -l --git-repos --git";
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos with fish";
      lg = "lazygit";
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
      update = "nix flake update nixpkgs nixpkgs-unstable nixos-hardware && sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
      nclean = "sudo nix-collect-garbage";
      claude = "NIXPKGS_ALLOW_UNFREE=1 nix-shell -p claude-code --run claude";
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

  home.packages =
    # General tools — 26.05, stable ABI
    (with pkgs; [
      eza                   # modern ls replacement (used by the l alias)
      lazygit               # terminal UI for git
      ripgrep               # fast grep, used by Telescope live grep
      bat                   # nice cat
      tmux                  # terminal multiplexer
      gcc                   # C compiler, also used to build treesitter parsers
    ])
    ++
    # Dev tools — unstable, latest versions
    (with pkgs-unstable; [
      neovim                # text editor — latest release
      tree-sitter           # CLI that nvim-treesitter uses to compile parsers
      clang-tools           # clangd language server and clang-format for C/C++
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
      # nodejs              # JavaScript runtime
      # rustc               # Rust compiler
      # cargo               # Rust build tool and package manager
      # rust-analyzer       # Rust language server
      # rustfmt             # Rust formatter
    ]);
}
