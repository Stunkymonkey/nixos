{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.fritzbox;
in
{
  options.my.services.fritzbox = with lib; {
    enable = mkEnableOption "Fritzbox-Monitoring";
    port = mkOption {
      type = types.port;
      default = 9787;
      example = 8080;
      description = "Internal port";
    };

    username = mkOption {
      type = types.str;
      default = "prometheus";
      example = "admin";
      description = "Admin username";
    };

    passwordFile = mkOption {
      type = types.str;
      example = "/var/lib/fritz/password.txt";
      description = "password stored in a file";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus.exporters.fritz = {
        inherit (cfg) enable port;
        settings.devices = [
          {
            inherit (cfg) username;
            password_file = cfg.passwordFile;
            host_info = true;
          }
        ];
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "fritzbox";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString cfg.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
      grafana.provision = {
        dashboards.settings.providers = [
          {
            name = "Fritzbox";
            options.path = pkgs.grafana-dashboards.fritzbox;
            disableDeletion = true;
          }
        ];
      };
    };
  };
}
