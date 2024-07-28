{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.usb-iso;
in
{
  options.my.profiles.usb-iso = with lib; {
    enable = mkEnableOption "usb-iso profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ventoy-bin-full # general
      woeusb-ng # windows
    ];
  };
}
