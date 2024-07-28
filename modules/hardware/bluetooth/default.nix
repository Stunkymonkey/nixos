{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.bluetooth;
in
{
  options.my.hardware.bluetooth = with lib; {
    enable = mkEnableOption "bluetooth configuration";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    services.blueman.enable = true;
    environment.systemPackages = with pkgs; [ sony-headphones-client ];
  };
}
