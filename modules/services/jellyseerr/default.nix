# manages and downloads films
{ config, lib, ... }:
let
  cfg = config.my.services.jellyseerr;
  inherit (config.networking) domain;
in
{
  options.my.services.jellyseerr = with lib; {
    enable = mkEnableOption "Sonarr for films management";
  };

  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
    };

    systemd.services.jellyseerr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
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
        link = "https://view.${domain}";
      };
    };
  };
}
