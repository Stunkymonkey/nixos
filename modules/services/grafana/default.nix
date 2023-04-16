# visualize monitoring services
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.grafana;
  domain = config.networking.domain;
in
{
  options.my.services.grafana = with lib; {
    enable = mkEnableOption "Grafana for visualizing";

    port = mkOption {
      type = types.port;
      default = 9500;
      example = 3001;
      description = "Internal port";
    };

    username = mkOption {
      type = types.str;
      default = "felix";
      example = "admin";
      description = "Admin username";
    };

    passwordFile = mkOption {
      type = types.str;
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
          http_port = cfg.port;
          http_addr = "127.0.0.1";
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
              targets = [ "127.0.0.1:${toString cfg.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "visualization";
        inherit (cfg) port;
      }
    ];

    webapps.apps.grafana = {
      dashboard = {
        name = "Visualization";
        category = "infra";
        icon = "chart-line";
        link = "https://visualization.${domain}";
      };
    };
  };
}
