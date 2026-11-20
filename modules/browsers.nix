# Firefox and Chromium, configured through enterprise policies:
# - spell checking in English + Dutch
# - uBlock Origin installed and enabled automatically
#
# Extension IDs (checked against the official stores, both by Raymond Hill):
# - Firefox:  uBlock Origin       uBlock0@raymondhill.net
#             https://addons.mozilla.org/firefox/addon/ublock-origin/
# - Chromium: uBlock Origin Lite  ddkjiahejlhfcafbddmgiahcphecmpfh
#             https://chromewebstore.google.com/detail/ddkjiahejlhfcafbddmgiahcphecmpfh
#   Chromium dropped Manifest V2, so the classic uBlock Origin
#   (cjpalhdlnbpafiamejdnhcphjbkeiagm) no longer runs there; Lite is the MV3 version.
{
  flake.modules.nixos.browsers = { pkgs, ... }: {
    programs.firefox = {
      enable = true;

      policies.ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          private_browsing = true;
        };
        # Dutch dictionary (OpenTaal word list) — Firefox ships only en-US.
        "nl-NL@dictionaries.addons.mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/woordenboek-nederlands/latest.xpi";
        };
      };

      # Check spelling in English and Dutch at the same time. "default" = you can
      # still change it in the browser; it just starts out with these values.
      preferencesStatus = "default";
      preferences = {
        "spellchecker.dictionary" = "en-US,nl";
      };
    };

    # Chromium reads these from /etc/chromium/policies/managed.
    programs.chromium = {
      enable = true;
      extensions = [
        "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      ];
      extraOpts = {
        SpellcheckEnabled = true;
        # Chromium downloads these dictionaries itself on first use.
        SpellcheckLanguage = [ "en-US" "nl" ];
      };
    };
    # programs.chromium only writes policies, it doesn't install the browser.
    environment.systemPackages = [ pkgs.chromium ];
  };
}
