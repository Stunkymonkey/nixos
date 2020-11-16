{ config, lib, pkgs, ... }:

#FIXME: komplett anpassen
let
  uuids = import ./vars-uuids.nix;
in
{
  boot.initrd.luks.devices."luks-drive" = {
    name = "luks-drive";
    device = "/dev/disk/by-partuuid/${uuids.luks.root}";
    preLVM = true;
    allowDiscards = true;
  };

  # FS
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${uuids.fs.root}";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${uuids.fs.boot}";
    fsType = "vfat";
  };

  # Swap
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/${uuids.fs.swap}";
    }
  ];
}
