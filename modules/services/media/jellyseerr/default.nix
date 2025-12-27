# manages and downloads films
{ config, lib, ... }:
let
  cfg = config.my.services.jellyseerr;
  inherit (config.networking) domain;
in
{
  options.my.services.jellyseerr = {
    enable = lib.mkEnableOption "Sonarr for films management";
  };

  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "view";
        inherit (config.services.jellyseerr) port;
      }
    ];

    webapps.apps.jellyseerr = {
      dashboard = {
        name = "View";
        category = "media";
        icon = "users-viewfinder";
        url = "https://view.${domain}";
      };
    };
  };
}
