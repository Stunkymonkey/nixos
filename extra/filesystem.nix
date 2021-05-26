{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    davfs2
    exfat
    exfat-utils
    fuse3
    hfsprogs
    mtpfs
    nfs-utils
    ntfs3g
    sshfs
  ];
}
