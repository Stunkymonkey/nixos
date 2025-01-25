# manages indexes
{ config, lib, ... }:
let
  cfg = config.my.services.prowlarr;
  inherit (config.networking) domain;
  port = 9696;
in
{
  options.my.services.prowlarr = with lib; {
    enable = mkEnableOption "Prowlarr for indexing";

    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        File containing the api-key.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      prowlarr = {
        enable = true;
      };
      prometheus.exporters.exportarr-prowlarr = {
        inherit (config.services.prometheus) enable;
        port = port + 1;
        url = "http://localhost:${toString port}";
        inherit (cfg) apiKeyFile;
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "prowlarr";
          static_configs = [
            {
              targets = [ "localhost:${toString port + 1}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "indexer";
        inherit port;
      }
    ];

    webapps.apps.prowlarr = {
      dashboard = {
        name = "Indexer";
        category = "app";
        icon = "sync-alt";
        url = "https://indexer.${domain}";
        method = "get";
      };
    };
  };
}
