{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    davfs2
    exfat
    fuse3
    hfsprogs
    mtpfs
    nfs-utils
    ntfs3g
    sshfs
  ];
}
