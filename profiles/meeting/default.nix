{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.meeting;
in
{
  options.my.profiles.meeting = with lib; {
    enable = mkEnableOption "meeting profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      element-desktop
      fractal
      mumble
      teamspeak5_client
    ];
  };
}
