# # log forwarding
{ config, lib, ... }:
let
  cfg = config.my.services.promtail;
  domain = config.networking.domain;
in
{
  options.my.services.promtail = with lib; {
    enable = mkEnableOption "promtail log forwarding";

    port = mkOption {
      type = types.port;
      default = 9081;
      example = 3002;
      description = "Internal port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = cfg.port;
          grpc_listen_port = 0; # without it collides with loki; only used for pushing (not used)
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [{
          url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
        }];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "24h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [{
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }];
          }
          {
            job_name = "nginx";
            static_configs = [
              {
                targets = [
                  "localhost"
                ];
                labels = {
                  job = "nginx";
                  __path__ = "/var/log/nginx/*.log";
                  host = config.networking.hostName;
                };
              }
            ];
          }
        ];
      };
    };

    # otherwise access to the log is denied
    users.users.promtail.extraGroups = [ "nginx" ];

    my.services.prometheus.rules = {
      promtail_request_errors = {
        condition = ''100 * sum(rate(promtail_request_duration_seconds_count{status_code=~"5..|failed"}[1m])) by (namespace, job, route, instance) / sum(rate(promtail_request_duration_seconds_count[1m])) by (namespace, job, route, instance) > 10'';
        time = "15m";
        description = ''{{ $labels.job }} {{ $labels.route }} is experiencing {{ printf "%.2f" $value }}% errors'';
      };

      promtail_file_lagging = {
        condition = ''abs(promtail_file_bytes_total - promtail_read_bytes_total) > 1e6'';
        time = "15m";
        description = ''{{ $labels.instance }} {{ $labels.job }} {{ $labels.path }} has been lagging by more than 1MB for more than 15m'';
      };
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "log";
        inherit (cfg) port;
      }
    ];

    webapps.apps.promtail = {
      dashboard = {
        name = "Logging";
        category = "infra";
        icon = "book";
        link = "https://log.${domain}";
      };
    };
  };
}
