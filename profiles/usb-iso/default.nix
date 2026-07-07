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
  options.my.profiles.usb-iso = {
    enable = lib.mkEnableOption "usb-iso profile";
  };

  config = lib.mkIf cfg.enable {
    # binary blobs are needed for ventoy
    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-${pkgs.ventoy.version}"
    ];
    environment.systemPackages = with pkgs; [
      ventoy-full # general
      woeusb-ng # windows
    ];
  };
}
