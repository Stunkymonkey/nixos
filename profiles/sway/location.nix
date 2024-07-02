{ config, lib, ... }:
let
  cfg = config.my.profiles.sway-location;
in
{
  options.my.profiles.sway-location = with lib; {
    enable = mkEnableOption "sway-location profile";
  };

  config = lib.mkIf cfg.enable {
    location.provider = "geoclue2";

    services.geoclue2 = {
      enable = true;
      enableDemoAgent = true;

      appConfig."gammastep" = {
        desktopID = "gammastep";
        isAllowed = true;
        isSystem = false;
      };
      appConfig."gammastep-indicator" = {
        desktopID = "gammastep-indicator";
        isAllowed = true;
        isSystem = false;
      };
    };
  };
}
