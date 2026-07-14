# public webserver with reverseproxy
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.webserver;
  inherit (config.networking) domain;

  virtualHostOption = lib.types.submodule {
    options = {
      subdomain = lib.mkOption {
        type = lib.types.str;
        example = "dev";
        description = ''
          Which subdomain, under config.networking.domain, to use
          for this virtual host.
        '';
      };
      port = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        default = null;
        example = 8080;
        description = ''
          Which port to proxy to, through localhost, for this virtual host.
          This option is incompatible with `root`.
        '';
      };
      root = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/var/www/blog";
        description = ''
          The root folder for this virtual host.  This option is incompatible
          with `port`.
        '';
      };
      extraConfig = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        example = lib.literalExpression ''
          {
            locations."/socket" = {
              proxyPass = "http://localhost:8096/";
              proxyWebsockets = true;
            };
          }
        '';
        default = null;
        description = ''
          Any extra configuration that should be applied to this virtual host.
        '';
      };
    };
  };

in
{
  options.my.services.webserver = {
    enable = lib.mkEnableOption "webserver";
    virtualHosts = lib.mkOption {
      type = lib.types.listOf virtualHostOption;
      default = [ ];
      example = lib.literalExpression ''
        [
          {
            subdomain = "gitea";
            port = 8080;
          }
          {
            subdomain = "dev";
            root = "/var/www/dev";
          }
          {
            subdomain = "jellyfin";
            port = 8096;
            extraConfig = {
              locations."/socket" = {
                proxyPass = "http://localhost:8096/";
                proxyWebsockets = true;
              };
            };
          }
        ]
      '';
      description = ''
        List of virtual hosts to set-up using default settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.allUnique (lib.filter (p: p != null) (map (v: v.port) cfg.virtualHosts));
        message =
          let
            portsWithSubdomains = lib.filter (v: v.port != null) cfg.virtualHosts;
            duplicates = lib.filter (
              p: lib.length (lib.filter (x: x.port == p.port) portsWithSubdomains) > 1
            ) portsWithSubdomains;
          in
          if duplicates == [ ] then
            ""
          else
            "Duplicate ports found in my.services.webserver.virtualHosts: "
            + lib.concatStringsSep ", " (map (v: v.subdomain + ":" + toString v.port) duplicates);
      }
    ];

    services = {
      nginx.enable = false;
      caddy = {
        enable = true;
        email = "server@buehler.rocks";

        globalConfig = ''
          metrics
        '';
        extraConfig = ''
          (compress) {
            encode gzip zstd
          }
          (headers) {
            header {
              # enable CORS
              Access-Control-Allow-Origin "https://${config.networking.domain}"
              # disable FLoC tracking
              Permissions-Policy interest-cohort=()
              # enable HSTS
              Strict-Transport-Security max-age=31536000;
              # disable clients from sniffing the media type
              X-Content-Type-Options "nosniff"
              # clickjacking protection
              X-Frame-Options "DENY"
              # enable XSS protection
              X-XSS-Protection "1; mode=block"
              # referrer policy
              Referrer-Policy "strict-origin-when-cross-origin"
            }
          }
          (common) {
            import headers
            import compress
          }
        '';

        virtualHosts =
          let
            mkVHost =
              { subdomain, ... }@args:
              lib.nameValuePair "${subdomain}.${domain}" (
                lib.foldl lib.recursiveUpdate { } [
                  {
                    useACMEHost = domain;
                    extraConfig = ''
                      import common
                      ${lib.optionalString (args.root != null) ''
                        root * ${args.root}
                        file_server
                      ''}
                      ${lib.optionalString (args.port != null) ''
                        reverse_proxy localhost:${toString args.port} {
                          # TODO: remove CORS headers from proxied server, because duplicate headers are not allowed
                          # navidrome hardcodes Access-Control-Allow-Origin: * on most routes; remove once configurable/removed upstream: https://github.com/navidrome/navidrome/blob/fe6ac2e577f14090a2fb33a9e4c91c1bee6196a7/server/middlewares.go#L89
                          header_down -Access-Control-Allow-Origin
                        }
                      ''}
                      ${lib.optionalString (args.extraConfig != null) args.extraConfig}
                    '';
                  }
                ]
              );
          in
          lib.listToAttrs (map mkVHost cfg.virtualHosts)
          // {
            # Catch-all for subdomains without a vhost above (e.g. wildcard DNS).
            "*.${domain}" = {
              useACMEHost = domain;
              extraConfig = "abort";
            };
          };
      };

      prometheus.scrapeConfigs = [
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = [ "localhost:2019" ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
      ];

      grafana.provision = {
        dashboards.settings.providers = [
          {
            name = "Caddy";
            options.path = pkgs.grafana-dashboards.caddy;
            disableDeletion = true;
          }
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
