{ config, lib, pkgs, ... }:

{
  location.provider = "geoclue2";

  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;

    appConfig."gammastep" = {
      desktopID = "gammastep";
      isAllowed = true;
      isSystem = false;
      # Empty list allows all users
      users = [ ];
    };
    appConfig."gammastep-indicator" = {
      desktopID = "gammastep-indicator";
      isAllowed = true;
      isSystem = false;
      # Empty list allows all users
      users = [ ];
    };

  };
}
