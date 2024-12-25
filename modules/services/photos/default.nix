# self-hosted photo gallery
{ config, lib, ... }:
let
  cfg = config.my.services.photos;
  inherit (config.networking) domain;
in
{
  options.my.services.photos = {
    enable = lib.mkEnableOption (lib.mdDoc "Photos gallery");

    secretsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = lib.mdDoc ''
        pass secrets
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
      description = lib.mdDoc ''
        Web interface port.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.anything;
      default = { };
      description = ''
        see <https://immich.app/docs/install/config-file/>.
      '';
    };

    path = lib.mkOption {
      type = lib.types.path;
      default = null;
      example = "/data/photos";
      description = lib.mdDoc ''
        Storage path of your original media files (photos and videos)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      # mediaLocation = path;
      inherit (cfg)
        secretsFile
        port
        ;
      settings = {
        ffmpeg.transcode = "disabled";
        server.externalDomain = "https://photos.${domain}";
      } // cfg.settings;
      environment = {
        IMMICH_TELEMETRY_INCLUDE = "all";
        IMMICH_API_METRICS_PORT = toString (cfg.port + 1);
        IMMICH_MICROSERVICES_METRICS_PORT = toString (cfg.port + 2);
      };
    };

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "immich";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString (cfg.port + 1)}" ];
              labels = {
                instance = config.networking.hostName;
                service = "api";
              };
            }
            {
              targets = [ "127.0.0.1:${toString (cfg.port + 2)}" ];
              labels = {
                instance = config.networking.hostName;
                service = "server";
              };
            }
          ];
        }
      ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "photos";
        inherit (cfg) port;
        extraConfig = {
          locations."/" = {
            proxyWebsockets = true;
            extraConfig = ''
              # Allow large file uploads
              client_max_body_size 1G;

              # Configure timeout
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
              send_timeout       600s;
            '';
          };
        };
      }
    ];

    webapps.apps.photos = {
      dashboard = {
        name = "Photos";
        category = "media";
        icon = "image";
        url = "https://photos.${domain}";
        method = "get";
      };
    };
  };
}
