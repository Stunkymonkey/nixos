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
    # binary blobs are needed for ventoy
    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-1.1.07"
    ];
    environment.systemPackages = with pkgs; [
      ventoy-full # general
      woeusb-ng # windows
    ];
  };
}
