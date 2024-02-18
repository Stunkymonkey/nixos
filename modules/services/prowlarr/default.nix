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
      description = lib.mdDoc ''
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
        url = "http://127.0.0.1:${toString port}";
        inherit (cfg) apiKeyFile;
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "prowlarr";
          static_configs = [{
            targets = [ "127.0.0.1:${toString port + 1}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
      ];
    };

    systemd.services.prowlarr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
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
