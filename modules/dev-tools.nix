# Dev tools — from pkgs.unstable (see modules/nix.nix) for the latest versions.
{
  flake.modules.homeManager.dev-tools = { pkgs, ... }: {
    home.packages = with pkgs.unstable; [
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
    ];
  };
}
