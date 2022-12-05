# Deployed services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  sops.secrets."borgbackup/password" = { };
  sops.secrets."borgbackup/private_ssh_key" = { };

  # List services that you want to enable:
  my.services = {
    backup = {
      enable = true;
      OnFailureMail = "server@buehler.rocks";
      passwordFile = secrets."borgbackup/password".path;
      sshKeyFile = secrets."borgbackup/private_ssh_key".path;
    };

    ssh-server = {
      enable = true;
    };

    jellyfin = {
      enable = true;
    };
  };
}
