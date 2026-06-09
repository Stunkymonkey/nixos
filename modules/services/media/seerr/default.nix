# manages and downloads films
{ config, lib, ... }:
let
  cfg = config.my.services.seerr;
  inherit (config.networking) domain;
in
{
  options.my.services.seerr = {
    enable = lib.mkEnableOption "Sonarr for films management";
  };

  config = lib.mkIf cfg.enable {
    services.seerr = {
      enable = true;
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "view";
        inherit (config.services.seerr) port;
      }
    ];

    webapps.apps.seerr = {
      dashboard = {
        name = "View";
        category = "media";
        icon = "users-viewfinder";
        url = "https://view.${domain}";
      };
    };
  };
}
