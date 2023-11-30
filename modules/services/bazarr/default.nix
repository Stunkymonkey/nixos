# manages and downloads subtitles
{ config, lib, ... }:
let
  cfg = config.my.services.bazarr;
  inherit (config.networking) domain;
  port = 6767;
in
{
  options.my.services.bazarr = with lib; {
    enable = mkEnableOption "Bazarr for subtitle management";

    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
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
        url = "http://127.0.0.1:${toString port}";
        inherit (cfg) apiKeyFile;
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "bazarr";
          static_configs = [{
            targets = [ "127.0.0.1:${toString port + 1}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
      ];
    };

    systemd.services.bazarr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
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
