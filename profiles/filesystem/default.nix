{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.filesystem;
in
{
  options.my.profiles.filesystem = with lib; {
    enable = mkEnableOption "filesystem profile";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
