# OpenSSH server: key-only login, no root.
# Authorized keys are set per host.
{
  flake.modules.nixos.ssh-server = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
