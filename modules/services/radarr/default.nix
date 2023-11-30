# manages and downloads films
{ config, lib, ... }:
let
  cfg = config.my.services.radarr;
  inherit (config.networking) domain;
  port = 7878;
in
{
  options.my.services.radarr = with lib; {
    enable = mkEnableOption "Radarr for film management";

    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        File containing the api-key.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      radarr = {
        enable = true;
      };
      prometheus.exporters.exportarr-radarr = {
        inherit (config.services.prometheus) enable;
        port = port + 1;
        url = "http://127.0.0.1:${toString port}";
        inherit (cfg) apiKeyFile;
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "radarr";
          static_configs = [{
            targets = [ "127.0.0.1:${toString port + 1}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
      ];
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

    webapps.apps.radarr = {
      dashboard = {
        name = "Movies";
        category = "media";
        icon = "film";
        url = "https://movies.${domain}";
      };
    };
  };
}
