# A FLOSS self-hosted, subsonic compatible music server
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.navidrome;
  domain = config.networking.domain;
in
{
  options.my.services.navidrome = with lib; {
    enable = mkEnableOption "Navidrome Music Server";

    settings = mkOption {
      type = (pkgs.formats.json { }).type;
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

    port = mkOption {
      type = types.port;
      default = 4533;
      example = 8080;
      description = "Internal port for webui";
    };

    musicFolder = mkOption {
      type = types.str;
      example = "/mnt/music/";
      description = "Music folder";
    };
  };

  config = lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;

      settings = cfg.settings // {
        Port = cfg.port;
        Address = "127.0.0.1";
        MusicFolder = cfg.musicFolder;
        LogLevel = "info";
        Prometheus.Enabled = config.services.prometheus.enable;
      };
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "music";
        inherit (cfg) port;
      }
    ];

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "navidrome";
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
    };
    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Navidrome";
          options.path = pkgs.grafana-dashboards.navidrome;
          disableDeletion = true;
        }
      ];
    };

    webapps.apps.navidrome = {
      dashboard = {
        name = "Music";
        category = "media";
        icon = "music";
        link = "https://music.${domain}/app/#/login";
      };
    };
  };
}
