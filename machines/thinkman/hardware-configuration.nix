{ config, lib, ... }:
{
  # video driver
  boot.initrd.kernelModules = [ "i915" ];

  # Special power management settings for ThinkPads
  services.tlp.enable = true;

  my.hardware = {
    keychron.enable = true;
    nitrokey.enable = true;
    sound.enable = true;
    thunderbolt.enable = true;
    firmware = {
      enable = true;
      cpuFlavor = "intel";
    };
  };
}
