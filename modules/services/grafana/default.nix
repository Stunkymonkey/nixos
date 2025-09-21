# visualize monitoring services
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.grafana;
  inherit (config.networking) domain;
in
{
  options.my.services.grafana = {
    enable = lib.mkEnableOption "Grafana for visualizing";

    username = lib.mkOption {
      type = lib.types.str;
      default = "felix";
      example = "admin";
      description = "Admin username";
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      example = "/var/lib/grafana/password.txt";
      description = "Admin password stored in a file";
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server = {
          domain = "visualization.${domain}";
          root_url = "https://visualization.${domain}/";
        };

        security = {
          admin_user = cfg.username;
          admin_password = "$__file{${cfg.passwordFile}}";
        };
      };

      provision = {
        enable = true;
        dashboards.settings.providers = [
          {
            name = "Grafana";
            options.path = pkgs.grafana-dashboards.grafana;
            disableDeletion = true;
          }
        ];
      };
    };

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [ "localhost:${toString config.services.grafana.settings.server.http_port}" ];
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
        subdomain = "visualization";
        port = config.services.grafana.settings.server.http_port;
      }
    ];

    webapps.apps.grafana = {
      dashboard = {
        name = "Visualization";
        category = "infra";
        icon = "chart-line";
        url = "https://visualization.${domain}";
      };
    };
  };
}
