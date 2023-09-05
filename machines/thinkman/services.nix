# Deployed services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  sops.secrets."borgbackup/password" = { };
  sops.secrets."borgbackup/ssh_key" = { };

  # List services that you want to enable:
  my.services = {
    backup = {
      enable = true;
      OnFailureNotification = true;
      passwordFile = secrets."borgbackup/password".path;
      sshKeyFile = secrets."borgbackup/ssh_key".path;
      paths = [ "/" ];
    };
  };
}
