# manages and downloads series
{ config, lib, ... }:
let
  cfg = config.my.services.sonarr;
  inherit (config.networking) domain;
  # in 25.05 this might be configurable
  port = 8989;
in
{
  options.my.services.sonarr = {
    enable = lib.mkEnableOption "Sonarr for series management";

    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        File containing the api-key.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: remove when sonarr is updated to 5.x
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "aspnetcore-runtime-6.0.36"
    ];

    services = {
      sonarr = {
        enable = true;
      };
      prometheus.exporters.exportarr-sonarr = {
        inherit (config.services.prometheus) enable;
        port = port + 1;
        url = "http://localhost:${toString port}";
        inherit (cfg) apiKeyFile;
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "sonarr";
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
        subdomain = "series";
        inherit port;
      }
    ];

    webapps.apps.sonarr = {
      dashboard = {
        name = "Series";
        category = "media";
        icon = "tv";
        url = "https://series.${domain}";
        method = "get";
      };
    };
  };
}
