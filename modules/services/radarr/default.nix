# manages and downloads films
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.radarr;
  domain = config.networking.domain;
  port = 7878;
in
{
  options.my.services.radarr = with lib; {
    enable = mkEnableOption "Sonarr for films management";
  };

  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
    };

    systemd.services.radarr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "movies";
        inherit port;
      }
    ];

    my.services.exportarr.radarr = {
      port = port + 1;
      url = "http://127.0.0.1:${toString port}";
    };

    webapps.apps.radarr = {
      dashboard = {
        name = "Movies";
        category = "media";
        icon = "film";
        link = "https://movies.${domain}";
      };
    };
  };
}
