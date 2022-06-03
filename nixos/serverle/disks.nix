{ config, lib, pkgs, ... }:

{
  boot.initrd.luks.devices."luks-drive" = {
    name = "luks-drive";
    device = "/dev/sda";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/serverle-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/serverle-bo";
    fsType = "vfat";
  };

  fileSystems."/srv" = {
    device = "/dev/disk/by-label/serverle-srv";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/dev/disk/by-label/serverle-swap";
  }];
}

