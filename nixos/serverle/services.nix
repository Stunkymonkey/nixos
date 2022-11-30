# Deployed services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  # List services that you want to enable:
  my.services = {
    ssh-server = {
      enable = true;
    };

    jellyfin = {
      enable = true;
    };
  };
}
