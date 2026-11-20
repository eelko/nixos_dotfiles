# General user applications and CLI tools — from the stable 26.05 package set.
{
  flake.modules.homeManager.apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      alacritty             # default console preference
      eza                   # modern ls replacement (used by the l alias)
      lazygit               # terminal UI for git
      ripgrep               # fast grep, used by Telescope live grep
      bat                   # nice cat
      tmux                  # terminal multiplexer
      keepassxc             # password manager

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
    ];
  };
}
