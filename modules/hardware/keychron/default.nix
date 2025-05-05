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
    hardware.keyboard.qmk.enable = true;

    services.udev.packages = with pkgs; [
      via
    ];

    environment.systemPackages = with pkgs; [
      qmk
      via
    ];
  };
}
