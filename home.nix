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
    rofi = "rofi";
    tmux = "tmux";
    alacritty = "alacritty";
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

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

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

  # The above is a for loop running through configs and making statements like below
  # xdg.configFile."nvim" = {
  #  source = create_symlink "${dotfiles}/nvim";
  #  recursive = true;
  # };

  home.packages =
    # General tools — 26.05, stable ABI
    (with pkgs; [
      alacritty             # default console preference 
      eza                   # modern ls replacement (used by the l alias)
      lazygit               # terminal UI for git
      ripgrep               # fast grep, used by Telescope live grep
      bat                   # nice cat
      tmux                  # terminal multiplexer
      # Alacritty's startup program (config/alacritty/alacritty.toml):
      # re-attach to a detached tmux session if there is one, else start a new one.
      (writeShellScriptBin "tmux-attach-or-new" ''
        # Launched from inside tmux (e.g. `alacritty` typed in a pane)? Don't refuse as nested.
        unset TMUX
        # First session with no clients; "<attached>:<name>" so names may contain spaces.
        session=$(tmux list-sessions -F '#{session_attached}:#{session_name}' 2>/dev/null \
          | ${gawk}/bin/awk -F: '$1 == 0 { sub(/^[^:]*:/, ""); print; exit }')
        if [ -n "$session" ]; then
          exec tmux attach-session -t "$session"
        else
          exec tmux new-session
        fi
      '')
      gcc                   # C compiler, also used to build treesitter parsers
      # Tidal music streaming (Hi-Fi/Widevine via Electron). --disable-dev-shm-usage
      # works around a /dev/shm shared-memory crash (ESRCH) on this machine.
      (tidal-hifi.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/tidal-hifi --add-flags --disable-dev-shm-usage
        '';
      }))
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
      claude-code           # Ai sidekick
    ]);
}
