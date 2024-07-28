{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.keychron;
in
{
  options.my.hardware.keychron = {
    enable = lib.mkEnableOption "keychron configuration";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = with pkgs; [
      qmk-udev-rules
      via
    ];

    environment.systemPackages = with pkgs; [
      qmk
      via
    ];
  };
}
