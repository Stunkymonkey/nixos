{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.webcam;
in
{
  options.my.profiles.webcam = {
    enable = lib.mkEnableOption "webcam profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fswebcam
      # gnome.cheese does no longer work
    ];
  };
}
