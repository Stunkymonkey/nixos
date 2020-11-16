{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    davfs2
    fuse3
    hfsprogs
    mtpfs
    nfs-utils
    ntfs3g
    sshfs
  ];
}
