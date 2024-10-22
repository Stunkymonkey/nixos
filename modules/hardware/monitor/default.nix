{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.monitor;
in
{
  options.my.hardware.monitor = {
    enable = lib.mkEnableOption "monitor configuration";
  };

  config = lib.mkIf cfg.enable {
    hardware.i2c.enable = true;

    environment.systemPackages = with pkgs; [
      ddcutil
      ddcui
    ];
  };
}
