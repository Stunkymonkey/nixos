# enabled system services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.system = {
    docker.enable = true;
  };
}
