{ config, lib, ... }:
{
  # video driver
  boot.initrd.kernelModules = [ "i915" ];

  # Special power management settings for ThinkPads
  services.tlp.enable = true;
}
