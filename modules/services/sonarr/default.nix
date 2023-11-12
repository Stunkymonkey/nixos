# manages and downloads series
{ config, lib, ... }:
let
  cfg = config.my.services.sonarr;
  inherit (config.networking) domain;
  port = 8989;
in
{
  options.my.services.sonarr = with lib; {
    enable = mkEnableOption "Sonarr for series management";

    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        File containing the api-key.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
    };

    systemd.services.sonarr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "series";
        inherit port;
      }
    ];

    my.services.exportarr.sonarr = {
      port = port + 1;
      url = "http://127.0.0.1:${toString port}";
      inherit (cfg) apiKeyFile;
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "sonarr";
        static_configs = [{
          targets = [ "127.0.0.1:${toString port + 1}" ];
          labels = {
            instance = config.networking.hostName;
          };
        }];
      }
    ];

    webapps.apps.sonarr = {
      dashboard = {
        name = "Series";
        category = "media";
        icon = "tv";
        url = "https://series.${domain}";
      };
    };
  };
}
