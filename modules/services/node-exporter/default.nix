# monitoring system services
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.node-exporter;
  domain = config.networking.domain;
in
{
  options.my.services.node-exporter = with lib; {
    enable = mkEnableOption "Node-Exporter for monitoring";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9100;
          listenAddress = "127.0.0.1";
        };
        systemd = {
          enable = true;
          listenAddress = "127.0.0.1";
        };
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
        {
          job_name = "systemd";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
      ];
    };

    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Node Exporter";
          options.path = pkgs.grafana-dashboards.node-exporter;
          disableDeletion = true;
        }
        {
          name = "Systemd";
          options.path = pkgs.grafana-dashboards.node-systemd;
          disableDeletion = true;
        }
      ];
    };

    my.services.prometheus.rules = {
      disk_will_fill_in_4_hours = {
        condition = "predict_linear(node_filesystem_free[1h], 4 * 3600) < 0";
        time = "5m";
        description = "Disk would fill up in 4 hours. Please check the disk space";
        labels = {
          severity = "page";
        };
      };
    };
  };
}
