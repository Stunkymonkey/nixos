# monitoring system services
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.prometheus;
  domain = config.networking.domain;
in
{
  options.my.services.prometheus = with lib; {
    enable = mkEnableOption "Prometheus for monitoring";

    port = mkOption {
      type = types.port;
      default = 9090;
      example = 3002;
      description = "Internal port";
    };

    scrapeInterval = mkOption {
      type = types.str;
      default = "15s";
      example = "1m";
      description = "Scrape interval";
    };

    retentionTime = mkOption {
      type = types.str;
      default = "2y";
      example = "1m";
      description = "retention time";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      inherit (cfg) port;
      listenAddress = "127.0.0.1";

      inherit (cfg) retentionTime;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9100;
          listenAddress = "127.0.0.1";
        };
      };

      globalConfig = {
        scrape_interval = cfg.scrapeInterval;
      };

      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };

    services.grafana.provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          jsonData = {
            timeInterval = config.services.prometheus.globalConfig.scrape_interval;
          };
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Node Exporter";
          options.path = pkgs.grafana-dashboards.node-exporter;
          disableDeletion = true;
        }
      ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "monitoring";
        inherit (cfg) port;
      }
    ];

    webapps.apps.prometheus = {
      dashboard = {
        name = "Monitoring";
        category = "infra";
        icon = "heart-pulse";
        link = "https://monitoring.${domain}";
        method = "get";
      };
    };
  };
}
