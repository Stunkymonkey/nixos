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
    services.prowlarr = {
      enable = true;
    };
    # # ugly fix for service not having a homedirectory
    # users.users.prowlarr = {
    #   isSystemUser = true;
    #   home = "/var/lib/prowlarr";
    #   group = "prowlarr";
    #   uid = 61654;
    # };
    # users.groups.prowlarr = {
    #   gid = 61654;
    # };

    systemd.services.prowlarr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "indexer";
        inherit port;
      }
    ];

    my.services.exportarr.prowlarr = {
      port = port + 1;
      url = "http://127.0.0.1:${toString port}";
      inherit (cfg) apiKeyFile;
    };

    services.prometheus.scrapeConfigs = [
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

    webapps.apps.prowlarr = {
      dashboard = {
        name = "Indexer";
        category = "app";
        icon = "sync-alt";
        link = "https://indexer.${domain}";
      };
    };
  };
}
