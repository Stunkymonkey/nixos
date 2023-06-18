# monitoring system services
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.alertmanager;
  domain = config.networking.domain;
in
{
  options.my.services.alertmanager = with lib; {
    enable = mkEnableOption "Prometheus alertmanager for monitoring";
    port = mkOption {
      type = types.port;
      default = 9093;
      example = 3002;
      description = "Internal alertmanager port";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.prometheus.enable;
        message = ''
          Enable alertmanager without prometheus does not work. Please enable prometheus as well.
        '';
      }
    ];

    services.prometheus = {
      alertmanager = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = cfg.port;
        configuration = import ./config.nix;
        webExternalUrl = "https://alerts.${domain}";
        # fix issue: https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/4556
        extraFlags = [ "--cluster.advertise-address 127.0.0.1:${toString cfg.port}" ];
      };

      alertmanagers = [
        {
          static_configs = [
            {
              targets = [ "localhost:${toString cfg.port}" ];
            }
          ];
        }
      ];
      scrapeConfigs = [
        {
          job_name = "alertmanager";
          static_configs = [{
            targets = [ "127.0.0.1:${toString cfg.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
      ];
    };

    services.grafana.provision = {
      datasources.settings.datasources = [
        {
          name = "Alertmanager";
          type = "alertmanager";
          url = "http://127.0.0.1:${toString cfg.port}";
          jsonData = {
            implementation = "prometheus";
            handleGrafanaManagedAlerts = config.services.prometheus.enable;
          };
        }
      ];
    };

    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Alertmanager";
          options.path = pkgs.grafana-dashboards.alertmanager;
          disableDeletion = true;
        }
      ];
    };

    # for mail delivery
    services.postfix.enable = true;

    services.go-neb.config.services = [
      {
        ID = "alertmanager_service";
        Type = "alertmanager";
        UserId = config.my.services.matrix-bot.Username;
        Config = {
          # url contains "alertmanager_service" encoded as base64
          webhook_url = "http://localhost:4050/services/hooks/YWxlcnRtYW5hZ2VyX3NlcnZpY2U";
          rooms = {
            "${config.my.services.matrix-bot.RoomID}" = {
              #bots:nixos.org
              text_template = ''
                {{range .Alerts -}} [{{ .Status }}] {{index .Labels "alertname" }}: {{index .Annotations "description"}} {{ end -}}
              '';
              # $$severity otherwise envsubst replaces $severity with an empty string
              html_template = ''
                {{range .Alerts -}}
                  {{ $$severity := index .Labels "severity" }}
                  {{ if eq .Status "firing" }}
                    {{ if eq $$severity "critical"}}
                      <font color='red'><b>[FIRING - CRITICAL]</b></font>
                    {{ else if eq $$severity "warning"}}
                      <font color='orange'><b>[FIRING - WARNING]</b></font>
                    {{ else }}
                      <b>[FIRING - {{ $$severity }}]</b>
                    {{ end }}
                  {{ else }}
                    <font color='green'><b>[RESOLVED]</b></font>
                  {{ end }}
                  {{ index .Labels "alertname"}}: {{ index .Annotations "summary"}}
                  (
                    <a href="{{ index .Annotations "grafana" }}">📈 Grafana</a>,
                    <a href="{{ .GeneratorURL }}">🔥 Prometheus</a>,
                    <a href="{{ .SilenceURL }}">🔕 Silence</a>
                  )<br/>
                {{end -}}'';
              msg_type = "m.text"; # Must be either `m.text` or `m.notice`
            };
          };
        };
      }
    ];

    my.services.prometheus.rules = {
      alerts_silences_changed = {
        condition = ''abs(delta(alertmanager_silences{state="active"}[1h])) >= 1'';
        description = "alertmanager: number of active silences has changed: {{$value}}";
      };
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "alerts";
        inherit (cfg) port;
      }
    ];

    webapps.apps = {
      alertmanager.dashboard = {
        name = "Alerting";
        category = "infra";
        icon = "bell";
        link = "https://alerts.${domain}";
        method = "get";
      };
    };
  };
}
