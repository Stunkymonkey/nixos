{ config, lib, ... }:
let
  cpuFlavor = "intel";
in
{
  # video driver
  boot.initrd.kernelModules = [ "i915" ];

  # Special power management settings for ThinkPads
  services.tlp.enable = true;

  my.hardware = {
    bluetooth.enable = true;
    firmware = {
      enable = true;
      cpuFlavor = cpuFlavor;
    };
    graphics.cpuFlavor = cpuFlavor;
    keychron.enable = true;
    nitrokey.enable = true;
    sound.enable = true;
    thunderbolt.enable = true;
  };
}
