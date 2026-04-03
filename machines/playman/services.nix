# Deployed services
{ config, ... }:
let
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    "borgbackup/password" = { };
    "borgbackup/ssh_key" = { };
  };

  # List services that you want to enable:
  my.services = {
    backup = {
      enable = true;
      OnFailureMail = "server@buehler.rocks";
      passwordFile = secrets."borgbackup/password".path;
      sshKeyFile = secrets."borgbackup/ssh_key".path;
      paths = [ "/" ];
    };
    # remote build
    remote-build.enable = true;

    ssh-server = {
      enable = true;
    };
    initrd-ssh = {
      enable = true;
    };
    vpn = {
      enable = true;
    };
  };
}
