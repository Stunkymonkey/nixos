# log monitoring
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.loki;
  domain = config.networking.domain;
in
{
  options.my.services.loki = with lib; {
    enable = mkEnableOption "loki log monitoring";

    port = mkOption {
      type = types.port;
      default = 3100;
      example = 3002;
      description = "Internal port";
    };

    rules = mkOption {
      type = types.attrsOf
        (types.submodule {
          options = {
            condition = mkOption {
              type = types.str;
              description = ''
                Loki alert expression.
              '';
              example = ''count_over_time({job=~"secure"} |="sshd[" |~": Failed|: Invalid|: Connection closed by authenticating user" | __error__="" [15m]) > 15'';
              default = null;
            };
            description = mkOption {
              type = types.str;
              description = ''
                Loki alert message.
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
        });
      description = ''
        Defines the loki rules.
      '';
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.loki = {
      enable = true;
      configuration = {
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = cfg.port;
        };
        auth_enabled = false;

        common = {
          instance_addr = "127.0.0.1";
          ring.kvstore.store = "inmemory";
          replication_factor = 1;
          path_prefix = "/tmp/loki";
        };

        ruler = lib.mkIf config.my.services.alertmanager.enable {
          storage = {
            type = "local";
            local = {
              # having the "fake" directory is important, because loki is running in single-tenant mode
              directory = (pkgs.writeTextDir "fake/loki-rules.yml" (builtins.toJSON {
                groups = [
                  {
                    name = "alerting-rules";
                    rules = lib.mapAttrsToList
                      (name: opts: {
                        alert = name;
                        expr = opts.condition;
                        for = opts.time;
                        labels = opts.labels;
                        annotations.description = opts.description;
                      })
                      (cfg.rules);
                  }
                ];
              }));
            };
          };

          alertmanager_url = "http://127.0.0.1:${toString config.my.services.alertmanager.port}";
          enable_alertmanager_v2 = true;
        };

        schema_config = {
          configs = [{
            from = "2020-05-15";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }];
        };
      };
    };

    services.grafana.provision = {
      datasources.settings.datasources = [
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://127.0.0.1:${toString cfg.port}";
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Loki";
          options.path = pkgs.grafana-dashboards.loki;
          disableDeletion = true;
        }
      ];
    };

    my.services.loki.rules = {
      loki_highLogRate = {
        condition = ''sum by (host) (rate({unit="loki.service"}[1m])) > 60'';
        description = "Loki has a high logging rate";
      };
    };

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "loki";
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
  };
}
