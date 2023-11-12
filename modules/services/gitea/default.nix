# self-hosted git service
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.gitea;
  inherit (config.networking) domain;
in
{
  options.my.services.gitea = with lib; {
    enable = mkEnableOption "Gitea";
    port = mkOption {
      type = types.port;
      default = 3042;
      example = 8080;
      description = "Internal port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;
      settings = {
        server = {
          HTTP_PORT = cfg.port;
          ROOT_URL = "https://code.${domain}";
        };
        session.COOKIE_SECURE = true;
        service.DISABLE_REGISTRATION = true;
        ui.DEFAULT_THEME = "arc-green";
        log.LEVEL = "Warn";
        metrics.ENABLED = config.services.prometheus.enable;
      };
      lfs.enable = true;
    };

    # Proxy to Gitea
    my.services.nginx.virtualHosts = [
      {
        subdomain = "code";
        inherit (cfg) port;
      }
    ];

    my.services.backup = {
      paths = [
        config.services.gitea.lfs.contentDir
        config.services.gitea.repositoryRoot
      ];
    };

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "gitea";
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
    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Gitea";
          options.path = pkgs.grafana-dashboards.gitea;
          disableDeletion = true;
        }
      ];
    };

    my.services.prometheus.rules = {
      gitea = {
        condition = ''rate(promhttp_metric_handler_requests_total{job="gitea", code="500"}[5m]) > 3'';
        description = "{{$labels.instance}}: gitea instances error rate went up: {{$value}} errors in 5 minutes";
      };
    };

    webapps.apps.gitea = {
      dashboard = {
        name = "Code";
        category = "app";
        icon = "code-branch";
        url = "https://code.${domain}";
      };
    };
  };
}
