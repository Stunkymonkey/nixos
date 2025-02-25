# manages and downloads subtitles
{ config, lib, ... }:
let
  cfg = config.my.services.bazarr;
  inherit (config.networking) domain;
  port = config.services.bazarr.listenPort;
in
{
  options.my.services.bazarr = with lib; {
    enable = mkEnableOption "Bazarr for subtitle management";

    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        File containing the api-key.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      bazarr = {
        enable = true;
      };
      prometheus.exporters.exportarr-bazarr = {
        inherit (config.services.prometheus) enable;
        port = port + 1;
        url = "http://localhost:${toString port}";
        inherit (cfg) apiKeyFile;
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "bazarr";
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
        subdomain = "subtitles";
        inherit port;
      }
    ];

    webapps.apps.bazarr = {
      dashboard = {
        name = "Subtitles";
        category = "app";
        icon = "closed-captioning";
        url = "https://subtitles.${domain}";
      };
    };
  };
}
