# self-hosted photo gallery
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.photos;
  inherit (config.networking) domain;
  inherit (config.services.immich) port;
in
{
  options.my.services.photos = {
    enable = lib.mkEnableOption "Photos gallery";

    secretsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        pass secrets
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
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/data/photos";
      description = ''
        Storage path of your original media files (photos and videos)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      # TODO: drop this pin once nixpkgs 26.11 ships immich 3.x;
      # 26.05 is stuck on the EOL 2.x branch (CVE-2026-59258, CVE-2026-82272)
      package = pkgs.unstable.immich;
      # mediaLocation = path;
      inherit (cfg) secretsFile;
      settings = {
        ffmpeg.transcode = "disabled";
        server.externalDomain = "https://photos.${domain}";
      }
      // cfg.settings;
      environment = {
        IMMICH_TELEMETRY_INCLUDE = "all";
        IMMICH_API_METRICS_PORT = toString (port + 1);
        IMMICH_MICROSERVICES_METRICS_PORT = toString (port + 2);
      };
    };

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "immich";
          static_configs = [
            {
              targets = [ "localhost:${toString (port + 1)}" ];
              labels = {
                instance = config.networking.hostName;
                service = "api";
              };
            }
            {
              targets = [ "localhost:${toString (port + 2)}" ];
              labels = {
                instance = config.networking.hostName;
                service = "server";
              };
            }
          ];
        }
      ];
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "photos";
        inherit port;
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
