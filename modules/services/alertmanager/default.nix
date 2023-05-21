# monitoring system services
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.alertmanager;
  domain = config.networking.domain;
in
{
  options.my.services.alertmanager = with lib; {
    enable = mkEnableOption "Prometheus alertmanager for monitoring";
    port = mkOption {
      type = types.port;
      default = 9093;
      example = 3002;
      description = "Internal alertmanager port";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.prometheus.enable;
        message = ''
          Enable alertmanager without prometheus does not work. Please enable prometheus as well.
        '';
      }
    ];

    services.prometheus = {
      alertmanager = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = cfg.port;
        configuration = import ./config.nix;
        webExternalUrl = "https://alerts.${domain}";
        # fix issue: https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/4556
        extraFlags = [ "--cluster.advertise-address 127.0.0.1:${toString cfg.port}" ];
      };

      alertmanagers = [
        {
          static_configs = [
            {
              targets = [ "localhost:${toString cfg.port}" ];
            }
          ];
        }
      ];
      scrapeConfigs = [
        {
          job_name = "alertmanager";
          static_configs = [{
            targets = [ "127.0.0.1:${toString cfg.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
      ];
    };

    services.grafana.provision = {
      datasources.settings.datasources = [
        {
          name = "Alertmanager";
          type = "alertmanager";
          url = "http://127.0.0.1:${toString cfg.port}";
          jsonData = {
            implementation = "prometheus";
            handleGrafanaManagedAlerts = config.services.prometheus.enable;
          };
        }
      ];
    };

    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Alertmanager";
          options.path = pkgs.grafana-dashboards.alertmanager;
          disableDeletion = true;
        }
      ];
    };

    # for mail delivery
    services.postfix.enable = true;

    my.services.nginx.virtualHosts = [
      {
        subdomain = "alerts";
        inherit (cfg) port;
      }
    ];

    webapps.apps = {
      alertmanager.dashboard = {
        name = "Alerting";
        category = "infra";
        icon = "bell";
        link = "https://alerts.${domain}";
        method = "get";
      };
    };
  };
}
