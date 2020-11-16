{ config, lib, pkgs, ... }:

{
  services.smartd.enable = true;
  environment.systemPackages = with pkgs; [
    dmidecode
    f3
    hdparm
    lm_sensors
    pciutils
    smartmontools
    testdisk
  ];
}
