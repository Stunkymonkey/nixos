# monitoring system services
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.prometheus;
  inherit (config.networking) domain;
in
{
  options.my.services.prometheus = with lib; {
    enable = mkEnableOption "Prometheus for monitoring";

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

    # a good collections for alerts can be found here: https://samber.github.io/awesome-prometheus-alerts/rules#blackbox
    rules = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            condition = mkOption {
              type = types.str;
              description = ''
                Prometheus alert expression.
              '';
              example = ''disk_used_percent{mode!="ro"} >= 90'';
              default = null;
            };
            description = mkOption {
              type = types.str;
              description = ''
                Prometheus alert message.
              '';
              example = "Prometheus encountered value {{ $value }} with {{ $labels }}";
              default = null;
            };
            labels = mkOption {
              type = types.nullOr (types.attrsOf types.str);
              description = ''
                Additional alert labels.
              '';
              example = literalExpression ''
                { severity = "page" };
              '';
              default = { };
            };
            time = lib.mkOption {
              type = lib.types.str;
              description = ''
                Time until the alert is fired.
              '';
              example = "5m";
              default = "2m";
            };
          };
        }
      );
      description = ''
        Defines the prometheus rules.
      '';
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus = {
        enable = true;
        webExternalUrl = "https://monitor.${domain}";

        inherit (cfg) retentionTime;

        globalConfig = {
          scrape_interval = cfg.scrapeInterval;
        };

        ruleFiles = [
          (pkgs.writeText "prometheus-rules.yml" (
            builtins.toJSON {
              groups = [
                {
                  name = "alerting-rules";
                  rules = lib.mapAttrsToList (name: opts: {
                    alert = name;
                    expr = opts.condition;
                    for = opts.time;
                    inherit (opts) labels;
                    annotations = {
                      inherit (opts) description;
                      grafana = lib.optionalString config.services.grafana.enable "https://visualization.${domain}";
                    };
                  }) cfg.rules;
                }
              ];
            }
          ))
        ];

        scrapeConfigs = [
          {
            job_name = "prometheus";
            static_configs = [
              {
                targets = [ "localhost:${toString config.services.prometheus.port}" ];
                labels = {
                  instance = config.networking.hostName;
                };
              }
            ];
          }
        ];
      };

      grafana.provision = {
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            isDefault = true;
            url = "http://localhost:${toString config.services.prometheus.port}";
            jsonData = {
              prometheusType = "Prometheus";
              prometheusVersion = toString pkgs.prometheus.version;
              timeInterval = config.services.prometheus.globalConfig.scrape_interval;
            };
          }
        ];
        dashboards.settings.providers = [
          {
            name = "Prometheus";
            options.path = pkgs.grafana-dashboards.prometheus;
            disableDeletion = true;
          }
        ];
      };
    };

    my.services = {
      node-exporter.enable = true;

      prometheus.rules = {
        prometheus_too_many_restarts = {
          condition = ''changes(process_start_time_seconds{job=~"prometheus|alertmanager"}[15m]) > 2'';
          description = "Prometheus has restarted more than twice in the last 15 minutes. It might be crashlooping";
        };

        alert_manager_config_not_synced = {
          condition = ''count(count_values("config_hash", alertmanager_config_hash)) > 1'';
          description = "Configurations of AlertManager cluster instances are out of sync";
        };

        prometheus_not_connected_to_alertmanager = {
          condition = "prometheus_notifications_alertmanagers_discovered < 1";
          description = "Prometheus cannot connect the alertmanager\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        };

        prometheus_rule_evaluation_failures = {
          condition = "increase(prometheus_rule_evaluation_failures_total[3m]) > 0";
          description = "Prometheus encountered {{ $value }} rule evaluation failures, leading to potentially ignored alerts.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        };

        prometheus_template_expansion_failures = {
          condition = "increase(prometheus_template_text_expansion_failures_total[3m]) > 0";
          time = "0m";
          description = "Prometheus encountered {{ $value }} template text expansion failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        };
      };

      webserver.virtualHosts = [
        {
          subdomain = "monitor";
          inherit (config.services.prometheus) port;
        }
      ];

      backup.exclude = [ "/var/lib/prometheus2/data" ];
    };

    webapps.apps = {
      prometheus.dashboard = {
        name = "Monitoring";
        category = "infra";
        icon = "heart-pulse";
        url = "https://monitor.${domain}";
        method = "get";
      };
    };
  };
}
