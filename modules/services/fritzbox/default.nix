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
  options.my.services.fritzbox = {
    enable = lib.mkEnableOption "Fritzbox-Monitoring";

    username = lib.mkOption {
      type = lib.types.str;
      default = "prometheus";
      example = "admin";
      description = "Admin username";
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      example = "/var/lib/fritz/password.txt";
      description = "password stored in a file";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus.exporters.fritz = {
        inherit (cfg) enable;
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
              targets = [ "localhost:${toString config.services.prometheus.exporters.fritzbox.port}" ];
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
