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
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/tmp/loki";
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

    services.grafana.provision.datasources.settings.datasources = [
      {
        name = "Loki";
        type = "loki";
        access = "proxy";
        url = "http://localhost:${toString cfg.port}";
      }
    ];
  };
}
