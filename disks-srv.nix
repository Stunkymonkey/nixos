{ config, lib, pkgs, ... }:

let
  uuids = import ./vars-uuids.nix;
in
{
  # FS
  fileSystems."/srv" = {
    device = "/dev/disk/by-uuid/${uuids.fs.srv}";
    fsType = "ext4";
  };
}
