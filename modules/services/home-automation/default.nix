# home automation
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.home-automation;
  inherit (config.networking) domain;
in
{
  options.my.services.home-automation = with lib; {
    enable = mkEnableOption "home-assistant server";

    package = lib.mkPackageOption pkgs "home-assistant" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8123;
      description = lib.mdDoc ''
        Web interface port.
      '';
    };

    extraComponents = mkOption {
      type = types.listOf (types.enum cfg.package.availableComponents);
      example = literalExpression ''
        [
          "analytics"
          "default_config"
          "esphome"
          "my"
          "wled"
        ]
      '';
      default = [ ];
      description = mdDoc ''
          List
          of [ components ]
          (https://www.home-assistant.io/integrations/)
          that
          have
          their
          dependencies
          included in the package.

        The component name can be found in the URL, for example `https://www.home-assistant.io/integrations/ffmpeg/` would map to `ffmpeg`.
      '';
    };

    latitude = mkOption {
      type = types.nullOr (types.either types.float types.str);
      default = null;
      example = 52.3;
      description = mdDoc ''
        your location latitude. Impacts sunrise data.
      '';
    };

    longitude = mkOption {
      type = types.nullOr (types.either types.float types.str);
      default = null;
      example = 4.9;
      description = mdDoc ''
        your location longitude. Impacts sunrise data.
      '';
    };

    elevation = mkOption {
      type = types.nullOr (types.either types.float types.str);
      default = null;
      description = mdDoc ''
        your location elevation. Impacts sunrise data.
      '';
    };

    timezone = mkOption {
      type = types.str;
      default = "GMT";
      description = mdDoc ''
        your timezone.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      home-assistant = {
        enable = true;

        inherit (cfg) package;

        config = {
          default_config = { };
          homeassistant = {
            name = "Home";
            inherit (cfg) latitude longitude elevation;
            unit_system = "metric";
            time_zone = cfg.timezone;
            external_url = "https://automation.${domain}";
            internal_url = "http://127.0.0.1:${toString cfg.port}";
          };
          http = {
            server_port = cfg.port;
            use_x_forwarded_for = true;
            trusted_proxies = [
              "127.0.0.1"
              "::1"
            ];
          };
          prometheus.requires_auth = false;
        };

        extraComponents = [
          "backup"
          "esphome"
          "shelly"
          "prometheus"
        ] ++ cfg.extraComponents;
      };

      prometheus.scrapeConfigs = [
        {
          job_name = "home-assistant";
          metrics_path = "/api/prometheus";
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

      esphome.enable = true;
    };

    my.services.prometheus.rules = {
      homeassistant = {
        condition = ''homeassistant_entity_available{domain="persistent_notification", entity!~"persistent_notification.http_login|persistent_notification.recorder_database_migration"} >= 0'';
        description = "homeassistant notification {{$labels.entity}} ({{$labels.friendly_name}}): {{$value}}";
      };
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "automation";
        inherit (cfg) port;
        extraConfig = {
          locations."/" = {
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      }
      {
        subdomain = "esphome";
        inherit (config.services.esphome) port;
        extraConfig = {
          locations."/" = {
            proxyWebsockets = true;
          };
        };
      }
    ];

    webapps.apps = {
      home-assistant = {
        dashboard = {
          name = "Home-Automation";
          category = "infra";
          icon = "house-signal";
          url = "https://automation.${domain}";
          method = "get";
        };
      };
      esphome = {
        dashboard = {
          name = "Home-Firmware";
          category = "infra";
          icon = "house-laptop";
          url = "https://esphome.${domain}";
          method = "get";
        };
      };
    };
  };
}
