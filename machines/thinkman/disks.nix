{ config, lib, pkgs, ... }:

{
  boot.initrd.luks.devices."luks-drive" = {
    name = "luks-drive";
    device = "/dev/disk/by-partlabel/Crypt";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/thinkman-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/thinkman-bo";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/thinkman-home";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/dev/disk/by-label/thinkman-swap";
  }];
}
