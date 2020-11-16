{ config, lib, pkgs, ... }:

{
  location.provider = "geoclue2";

  services.geoclue2.enable = true;
  services.geoclue2.enableDemoAgent = true;
  services.geoclue2.appConfig."gammastep" = {
    desktopID = "gammastep";
    isAllowed = true;
    isSystem = false;
    # Empty list allows all users
    users = [ ];
  };

  services.geoclue2.appConfig."gammastep-indicator" = {
    desktopID = "gammastep-indicator";
    isAllowed = true;
    isSystem = false;
    # Empty list allows all users
    users = [ ];
  };

}
