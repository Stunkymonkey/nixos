{ config, lib, pkgs, ... }:

#FIXME: komplett anpassen
let
  uuids = import ./vars-uuids.nix;
in
{
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${uuids.fs.home}";
    fsType = "ext4";
  };
}
