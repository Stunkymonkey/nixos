# monitor urls
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.blackbox;
  blackBoxConfig = {
    modules = {
      http_2xx = {
        prober = "http";
        http.preferred_ip_protocol = "ip4";
      };
      ssh_banner = {
        prober = "tcp";
        tcp.query_response = [
          { send = "SSH-2.0-blackbox-ssh-check"; }
          { expect = "^SSH-2.0-"; }
        ];
      };
    };
  };
in
{
  options.my.services.blackbox = {
    enable = lib.mkEnableOption "Blackbox prometheus exporter";

    http_endpoints = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = lib.literalExpression ''
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
    services = {
      prometheus.exporters.blackbox = {
        enable = true;
        configFile = pkgs.writeText "blackbox-config.yml" (builtins.toJSON blackBoxConfig);
      };

      # relabels as in https://github.com/prometheus/blackbox_exporter#prometheus-configuration
      prometheus = {
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
                replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}";
              }
            ];
          }
        ];
      };
      grafana.provision.dashboards.settings.providers = [
        {
          name = "Blackbox";
          options.path = pkgs.grafana-dashboards.blackbox;
          disableDeletion = true;
        }
      ];
    };

    my.services.prometheus.rules = {
      BlackboxProbeFailed = {
        condition = "probe_success == 0";
        description = "Blackbox probe failed (instance {{ $labels.instance }}): {{$value}}";
        time = "1m";
        labels = {
          severity = "critical";
        };
      };
      BlackboxConfigurationReloadFailure = {
        condition = "blackbox_exporter_config_last_reload_successful != 1";
        description = "Blackbox configuration reload failure\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        time = "0m";
        labels = {
          severity = "warning";
        };
      };
      BlackboxSlowProbe = {
        condition = "avg_over_time(probe_duration_seconds[1m]) > 2";
        description = "Blackbox probe took more than 2s to complete\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        time = "1m";
        labels = {
          severity = "warning";
        };
      };
      BlackboxProbeHttpFailure = {
        condition = "probe_http_status_code <= 199 OR probe_http_status_code >= 400";
        description = "HTTP status code is not 200-399\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        time = "1m";
      };
      BlackboxSslCertificateWillExpireSoon = {
        condition = "3 <= round((last_over_time(probe_ssl_earliest_cert_expiry[10m]) - time()) / 86400, 0.1) < 20";
        description = "SSL certificate expires in less than 20 days\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        time = "0m";
        labels = {
          severity = "warning";
        };
      };
      BlackboxSslCertificateWillExpireShortly = {
        condition = "0 <= round((last_over_time(probe_ssl_earliest_cert_expiry[10m]) - time()) / 86400, 0.1) < 3";
        description = "SSL certificate expires in less than 3 days\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        time = "0m";
        labels = {
          severity = "critical";
        };
      };
      BlackboxProbeSlowHttp = {
        condition = "avg_over_time(probe_http_duration_seconds[1m]) > 2";
        description = "HTTP request took more than 2s\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        time = "1m";
        labels = {
          severity = "warning";
        };
      };
      BlackboxProbeSlowPing = {
        condition = "avg_over_time(probe_icmp_duration_seconds[1m]) > 1";
        description = "Blackbox ping took more than 1s\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
        time = "1m";
        labels = {
          severity = "warning";
        };
      };
    };
  };
}
