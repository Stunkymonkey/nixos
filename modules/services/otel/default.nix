# metric forwarding
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.otel;
  inherit (config.networking) domain;
in
{
  options.my.services.otel = {
    enable = lib.mkEnableOption "otel collection";

    port = lib.mkOption {
      type = lib.types.port;
      default = 12346;
      example = 12346;
      description = "Internal port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      extraFlags = [
        "--server.http.listen-addr=127.0.0.1:${toString cfg.port}"
        "--disable-reporting"
      ];
      configPath = pkgs.writeText "config.alloy" ''
        loki.relabel "journal" {
          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }
          forward_to = []
        }

        loki.source.journal "journal" {
          max_age    = "24h"

          labels = {
            job  = "systemd-journal",
            host = sys.env("HOSTNAME"),
          }

          relabel_rules = loki.relabel.journal.rules

          forward_to = [loki.write.default.receiver]
        }

        loki.write "default" {
          endpoint {
            url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
          }
        }
      '';
    };

    my.services.prometheus.rules = {
      GrafanaAlloyServiceDown = {
        condition = "count by (instance) (alloy_build_info offset 2h) unless count by (instance) (alloy_build_info)";
        time = "0m";
        description = "Grafana Alloy service down";
      };
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "otel";
        inherit (cfg) port;
      }
    ];

    webapps.apps.promtail = {
      dashboard = {
        name = "Telemetry";
        category = "infra";
        icon = "book";
        url = "https://otel.${domain}";
      };
    };
  };
}
