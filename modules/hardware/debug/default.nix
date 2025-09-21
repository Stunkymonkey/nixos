{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.debug;
in
{
  options.my.hardware.debug = {
    enable = lib.mkEnableOption "hardware-debug configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dmidecode
      f3
      hdparm
      lm_sensors
      nvme-cli
      pciutils
      smartmontools
      testdisk
    ];
  };
}
