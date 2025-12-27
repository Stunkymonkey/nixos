# A FLOSS self-hosted, subsonic compatible music server
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.navidrome;
  inherit (config.networking) domain;
in
{
  options.my.services.navidrome = {
    enable = lib.mkEnableOption "Navidrome Music Server";

    settings = lib.mkOption {
      inherit (pkgs.formats.json { }) type;
      default = {
        EnableSharing = true;
      };
      example = {
        "LastFM.ApiKey" = "MYKEY";
        "LastFM.Secret" = "MYSECRET";
        "Spotify.ID" = "MYKEY";
        "Spotify.Secret" = "MYSECRET";
      };
      description = ''
        Additional settings.
      '';
    };

    musicFolder = lib.mkOption {
      type = lib.types.str;
      example = "/mnt/music/";
      description = "Music folder";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      navidrome = {
        enable = true;

        settings = cfg.settings // {
          MusicFolder = cfg.musicFolder;
          LogLevel = "info";
          Prometheus.Enabled = config.services.prometheus.enable;
        };
      };

      prometheus = {
        scrapeConfigs = [
          {
            job_name = "navidrome";
            static_configs = [
              {
                targets = [ "localhost:${toString config.services.navidrome.settings.Port}" ];
                labels = {
                  instance = config.networking.hostName;
                };
              }
            ];
          }
        ];
      };
      grafana.provision = {
        dashboards.settings.providers = [
          {
            name = "Navidrome";
            options.path = pkgs.grafana-dashboards.navidrome;
            disableDeletion = true;
          }
        ];
      };
    };

    my.services.prometheus.rules = {
      navidrome_not_enough_albums = {
        condition = ''http_navidrome_album_count != 1'';
        description = "navidrome: not enough albums as expected: {{$value}}";
      };
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "music";
        port = config.services.navidrome.settings.Port;
      }
    ];

    webapps.apps.navidrome = {
      dashboard = {
        name = "Music";
        category = "media";
        icon = "music";
        url = "https://music.${domain}";
        method = "get";
      };
    };
  };
}
