# HedgeDoc is an open-source, web-based, self-hosted, collaborative markdown editor.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.hedgedoc;
  inherit (config.networking) domain;
in
{
  options.my.services.hedgedoc = with lib; {
    enable = mkEnableOption "Hedgedoc Music Server";

    settings = mkOption {
      inherit (pkgs.formats.json { }) type;
      default = { };
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
  };

  config = lib.mkIf cfg.enable {
    services = {
      hedgedoc = {
        enable = true;

        settings = {
          domain = "notes.${domain}";
          port = 3080;
          protocolUseSSL = true;
          db = {
            dialect = "sqlite";
            storage = "/var/lib/hedgedoc/hedgedoc.sqlite";
          };
        }
        // cfg.settings;
      };

      prometheus = {
        scrapeConfigs = [
          {
            job_name = "hedgedoc";
            static_configs = [
              {
                targets = [ "localhost:${toString config.services.hedgedoc.settings.port}" ];
                labels = {
                  instance = config.networking.hostName;
                };
              }
            ];
          }
        ];
      };

      grafana.provision.dashboards.settings.providers = [
        {
          name = "Hedgedoc";
          options.path = pkgs.grafana-dashboards.hedgedoc;
          disableDeletion = true;
        }
      ];
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "notes";
        inherit (config.services.hedgedoc.settings) port;
      }
    ];

    webapps.apps.hedgedoc = {
      dashboard = {
        name = "Notes";
        category = "app";
        icon = "edit";
        url = "https://notes.${domain}";
      };
    };
  };
}
