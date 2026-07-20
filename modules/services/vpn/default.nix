# self-hosted vpn
{ config, lib, ... }:
let
  cfg = config.my.services.vpn;
  inherit (config.networking) domain;
in
{
  options.my.services.vpn = {
    enable = lib.mkEnableOption "Headscale VPN";
    isMaster = lib.mkEnableOption "Headscale Master";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8090;
      example = 8080;
      description = "Internal port";
    };
    internalDomain = lib.mkOption {
      type = lib.types.str;
      default = "buehler.internal";
      description = "Internal DNS base domain for Headscale";
    };
    webInterface = {
      enable = lib.mkEnableOption "Headplane web interface for Headscale";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8092;
        example = 8080;
        description = "Internal port";
      };
      cookieSecretFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to a file containing the Headplane session cookie secret.
          Must be exactly 32 characters long.
        '';
        example = "/run/secrets/headplane/cookie_secret";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.tailscale.enable = true;
      }

      (lib.mkIf cfg.isMaster {

        services.headscale = {
          enable = true;
          inherit (cfg) port;
          settings = {
            dns.base_domain = cfg.internalDomain;
            dns.override_local_dns = false;
            server_url = "https://vpn.${domain}";
            metrics_listen_addr = "127.0.0.1:8091";
            log.level = "warn";
          };
        };

        services.prometheus = {
          scrapeConfigs = [
            {
              job_name = "headscale";
              static_configs = [
                {
                  targets = [ "localhost:8091" ];
                  labels = {
                    instance = config.networking.hostName;
                  };
                }
              ];
            }
          ];
        };

        # Proxy to Headscale
        my.services = {
          webserver.virtualHosts = [
            {
              subdomain = "vpn";
              inherit (cfg) port;
            }
          ];

          prometheus.rules = {
            HeadscaleHighErrorRate = {
              condition = ''rate(headscale_http_requests_total{status=~"5.."}[5m]) > 0.1'';
              description = "The error rate for Headscale server {{ $labels.instance }} is above 10% in the last 2 minutes.";
            };
          };
        };
      })

      (lib.mkIf (cfg.isMaster && cfg.webInterface.enable) {
        services.headplane = {
          enable = true;
          settings.server = {
            inherit (cfg.webInterface) port;
            cookie_secret_path = cfg.webInterface.cookieSecretFile;
          };
        };

        my.services.webserver.virtualHosts = [
          {
            subdomain = "vpn-admin";
            inherit (cfg.webInterface) port;
            # Headplane only serves its UI under /admin, not at the bare root.
            extraConfig = ''
              redir / /admin permanent
            '';
          }
        ];

        webapps.apps.vpn = {
          dashboard = {
            name = "VPN";
            category = "infra";
            icon = "shield-halved";
            url = "https://vpn-admin.${domain}";
          };
        };
      })
    ]
  );
}
