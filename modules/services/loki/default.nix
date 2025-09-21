# log monitoring
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.loki;
  # no default port defined in nixpkgs
  port = 3101;
in
{
  options.my.services.loki = {
    enable = lib.mkEnableOption "loki log monitoring";

    rules = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            condition = lib.mkOption {
              type = lib.types.str;
              description = ''
                Loki alert expression.
              '';
              example = ''count_over_time({job=~"secure"} |="sshd[" |~": Failed|: Invalid|: Connection closed by authenticating user" | __error__="" [15m]) > 15'';
              default = null;
            };
            description = lib.mkOption {
              type = lib.types.str;
              description = ''
                Loki alert message.
              '';
              example = "Prometheus encountered value {{ $value }} with {{ $labels }}";
              default = null;
            };
            labels = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
              description = ''
                Additional alert labels.
              '';
              example = lib.literalExpression ''
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
        Defines the loki rules.
      '';
      default = { };
    };
  };

  config =
    let
      rulerConfig = {
        groups = [
          {
            name = "alerting-rules";
            rules = lib.mapAttrsToList (name: opts: {
              alert = name;
              inherit (opts) condition labels;
              for = opts.time;
              annotations.description = opts.description;
            }) cfg.rules;
          }
        ];
      };
      rulerFile = pkgs.writeText "ruler.yml" (builtins.toJSON rulerConfig);
    in
    lib.mkIf cfg.enable {
      services = {
        loki = {
          enable = true;
          configuration = {
            server = {
              http_listen_address = "localhost";
              http_listen_port = port;
            };
            auth_enabled = false;

            common = {
              instance_addr = "localhost";
              ring.kvstore.store = "inmemory";
              replication_factor = 1;

              path_prefix = config.services.loki.dataDir;
              storage.filesystem = {
                chunks_directory = "${config.services.loki.dataDir}/chunks";
                rules_directory = "${config.services.loki.dataDir}/rules";
              };
            };

            ruler = lib.mkIf config.my.services.alertmanager.enable {
              storage = {
                type = "local";
                local.directory = "${config.services.loki.dataDir}/ruler";
              };
              rule_path = "${config.services.loki.dataDir}/rules";
              alertmanager_url = "http://localhost:${toString config.services.prometheus.alertmanager.port}";
              enable_alertmanager_v2 = true;
            };

            schema_config = {
              configs = [
                {
                  from = "2020-11-08";
                  store = "tsdb";
                  object_store = "filesystem";
                  schema = "v13";
                  index = {
                    prefix = "index_";
                    period = "24h";
                  };
                }
              ];
            };

            limits_config = {
              max_query_lookback = "672h"; # 28 days
              retention_period = "672h"; # 28 days
            };

            compactor = {
              working_directory = "${config.services.loki.dataDir}/compactor";
              retention_enabled = true;
              delete_request_store = "filesystem";
            };
          };
        };

        grafana.provision = {
          datasources.settings.datasources = [
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://localhost:${toString port}";
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

        prometheus = {
          scrapeConfigs = [
            {
              job_name = "loki";
              static_configs = [
                {
                  targets = [ "localhost:${toString port}" ];
                  labels = {
                    instance = config.networking.hostName;
                  };
                }
              ];
            }
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/loki 0700 loki loki - -"
        "d /var/lib/loki/ruler 0700 loki loki - -"
        "d /var/lib/loki/rules 0700 loki loki - -"
        "L /var/lib/loki/ruler/ruler.yml - - - - ${rulerFile}"
      ];
      systemd.services.loki.reloadTriggers = [ rulerFile ];

      my.services.loki.rules = {
        loki_highLogRate = {
          condition = ''sum by (host) (rate({unit="loki.service"}[1m])) > 60'';
          description = "Loki has a high logging rate";
        };
      };
    };
}
