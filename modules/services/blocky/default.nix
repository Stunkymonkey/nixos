# Fast and lightweight DNS proxy as ad-blocker for local network
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.blocky;
in
{
  options.my.services.blocky = {
    enable = lib.mkEnableOption "Blocky DNS Server";

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 8053;
      example = 8080;
      description = "port for requests";
    };

    settings = lib.mkOption {
      inherit (pkgs.formats.json { }) type;
      default = { };
      example = lib.literalExpression ''
        { ports.http = "8053" };
      '';
      description = ''
        Override settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      blocky = {
        enable = true;

        settings = {
          ports = {
            tls = "853";
            http = cfg.httpPort;
          };
          upstream = {
            default = [
              "dns2.digitalcourage.de2" # classic
              "tcp-tls:dns3.digitalcourage.de" # DoT
              "https://dns.digitale-gesellschaft.ch/dns-query" # DoH
            ];
          };
          prometheus.enable = config.services.prometheus.enable;
        }
        // cfg.settings;
      };

      prometheus.scrapeConfigs = [
        {
          job_name = "blocky";
          static_configs = [
            {
              targets = [ "localhost:${toString cfg.httpPort}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];

      # untested
      grafana.provision.dashboards.settings.providers = [
        {
          name = "Blocky";
          options.path = pkgs.grafana-dashboards.blocky;
          disableDeletion = true;
        }
      ];
    };
  };
}
