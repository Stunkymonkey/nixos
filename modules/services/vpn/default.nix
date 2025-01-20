# self-hosted vpn
{ config, lib, ... }:
let
  cfg = config.my.services.vpn;
  inherit (config.networking) domain;
in
{
  options.my.services.vpn = with lib; {
    enable = mkEnableOption "Headscale VPN";
    isMaster = mkEnableOption "Headscale Master";
    port = mkOption {
      type = types.port;
      default = 8099;
      example = 8080;
      description = "Internal port";
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
            dns.base_domain = "buehler.internal";
            server_url = "https://vpn.${domain}";
            metrics_listen_addr = "127.0.0.1:8095";
            log.level = "warn";
          };
        };

        services.prometheus = {
          scrapeConfigs = [
            {
              job_name = "headscale";
              static_configs = [
                {
                  targets = [ "localhost:8095" ];
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
          nginx.virtualHosts = [
            {
              subdomain = "vpn";
              inherit (cfg) port;
              extraConfig = {
                locations = {
                  "/" = {
                    proxyWebsockets = true;
                  };
                };
              };
            }
          ];

          prometheus.rules = {
            HeadscaleHighErrorRate = {
              condition = ''rate(headscale_http_requests_total{status=~"5.."}[5m]) > 0.1'';
              description = "The error rate for Headscale server {{ $labels.instance }} is above 10% in the last 2 minutes.";
            };
          };
        };

        # waiting for a nice web-ui
        # webapps.apps.vpn = {
        #   dashboard = {
        #     name = "VPN";
        #     category = "infra";
        #     icon = "shield-halved";
        #     url = "https://vpn.${domain}";
        #   };
        # };
      })
    ]
  );
}
