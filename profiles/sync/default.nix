{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.sync;
in
{
  options.my.profiles.sync = with lib; {
    enable = mkEnableOption "sync profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      croc
      magic-wormhole
      nextcloud-client
      syncthing
      vdirsyncer
    ];
  };
}
