# enabled system services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.system = {
    avahi.enable = true;
    podman.enable = true;
    virtualization = {
      enable = true;
      cpuFlavor = "intel";
    };
  };
}
