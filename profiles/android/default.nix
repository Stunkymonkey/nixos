{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.android;
in
{
  options.my.profiles.android = {
    enable = lib.mkEnableOption "android profile";
  };

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    environment.systemPackages = with pkgs; [ scrcpy ];
  };
}
