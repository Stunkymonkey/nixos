# monitor urls
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.blackbox;
  domain = config.networking.domain;
  blackBoxConfig = {
    modules = {
      http_2xx = {
        prober = "http";
        http.preferred_ip_protocol = "ip4";
      };
      ssh_banner = {
        prober = "tcp";
        tcp.query_response = [
          {
            send = "SSH-2.0-blackbox-ssh-check";
          }
          {
            expect = "^SSH-2.0-";
          }
        ];
      };
    };
  };
in
{
  options.my.services.blackbox = with lib; {
    enable = mkEnableOption "Blackbox prometheus exporter";

    http_endpoints = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression ''
        [
          "https://domain.com"
          "https://another-domain.com"
        ]
      '';
      description = ''
        List of domains to test.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.blackbox = {
      enable = true;
      configFile = pkgs.writeText "blackbox-config.yml" (builtins.toJSON blackBoxConfig);
    };

    # relabels as in https://github.com/prometheus/blackbox_exporter#prometheus-configuration
    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "blackbox";
          metrics_path = "/probe";
          params.module = [ "http_2xx" ];
          static_configs = [
            {
              targets = cfg.http_endpoints;
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}";
            }
          ];
        }
      ];
    };

    services.grafana.provision.dashboards.settings.providers = [
      {
        name = "Blackbox";
        options.path = pkgs.grafana-dashboards.blackbox;
        disableDeletion = true;
      }
    ];
  };
}
