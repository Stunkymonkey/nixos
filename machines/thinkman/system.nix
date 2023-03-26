# enabled system services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.system = {
    avahi.enable = true;
    kvm = {
      enable = true;
      cpuFlavor = "intel";
    };
    podman.enable = true;
  };
}
