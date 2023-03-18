{ config, lib, pkgs, ... }:

{
  boot.initrd.luks.devices."luks-drive" = {
    name = "luks-drive";
    device = "/dev/disk/by-partlabel/Crypt";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/newton-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/newton-boot";
    fsType = "vfat";
  };

  fileSystems."/srv" = {
    device = "/dev/disk/by-label/newton-srv";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/dev/disk/by-label/newton-swap";
  }];
}
