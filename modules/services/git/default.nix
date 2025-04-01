# self-hosted git service
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.git;
  inherit (config.networking) domain;
in
{
  options.my.services.git = {
    enable = lib.mkEnableOption "Git server";

    passwordFile = lib.mkOption {
      type = lib.types.path;
      example = "/var/lib/somewhere/password.txt";
      description = ''
        Path to a file containing the admin's password.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    # configure admin user
    systemd.services.forgejo.preStart =
      let
        adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        user = "felix";
      in
      ''
        admin="${adminCmd}"
        if ! $admin list | grep "${user}"; then
          ${adminCmd} create --admin --email "server@localhost" --username ${user} --password "$(tr -d '\n' < ${cfg.passwordFile})" || true
        else
          ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${cfg.passwordFile})" || true
        fi
      '';

    services = {
      forgejo = {
        enable = true;
        settings = {
          server = {
            HTTP_PORT = 3042;
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

      prometheus = {
        scrapeConfigs = [
          {
            job_name = "forgejo";
            static_configs = [
              {
                targets = [ "localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}" ];
                labels = {
                  instance = config.networking.hostName;
                };
              }
            ];
          }
        ];
      };
      grafana.provision = {
        dashboards.settings.providers = [
          {
            name = "Forgejo";
            options.path = pkgs.grafana-dashboards.forgejo;
            disableDeletion = true;
          }
        ];
      };
    };

    # Proxy to forgejo
    my.services = {
      webserver.virtualHosts = [
        {
          subdomain = "code";
          port = config.services.forgejo.settings.server.HTTP_PORT;
        }
      ];

      backup = {
        paths = [
          config.services.forgejo.lfs.contentDir
          config.services.forgejo.repositoryRoot
        ];
      };

      prometheus.rules = {
        forgejo = {
          condition = ''rate(promhttp_metric_handler_requests_total{job="forgejo", code="500"}[5m]) > 3'';
          description = "{{$labels.instance}}: forgejo instances error rate went up: {{$value}} errors in 5 minutes";
        };
      };
    };

    webapps.apps.git = {
      dashboard = {
        name = "Code";
        category = "app";
        icon = "code-branch";
        url = "https://code.${domain}";
      };
    };
  };
}
