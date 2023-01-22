{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.android;
in
{
  options.my.profiles.android = with lib; {
    enable = mkEnableOption "android profile";
  };

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    environment.systemPackages = with pkgs; [
      scrcpy
    ];
  };
}
