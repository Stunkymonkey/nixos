# HedgeDoc is an open-source, web-based, self-hosted, collaborative markdown editor.
{ config, lib, pkgs, ... }:
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

    port = mkOption {
      type = types.port;
      default = 3080;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hedgedoc = {
      enable = true;

      settings = {
        domain = "notes.${domain}";
        inherit (cfg) port;
        host = "127.0.0.1";
        protocolUseSSL = true;
        db = {
          dialect = "sqlite";
          storage = "/var/lib/hedgedoc/hedgedoc.sqlite";
        };
      } // cfg.settings;
    };

    # temporary fix for: https://github.com/NixOS/nixpkgs/issues/198250
    #systemd.services.hedgedoc.serviceConfig.StateDirectory = lib.mkForce "/var/lib/hedgedoc";
    systemd.services.hedgedoc.serviceConfig.StateDirectory = lib.mkForce "hedgedoc";

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "hedgedoc";
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

    services.grafana.provision.dashboards.settings.providers = [
      {
        name = "Hedgedoc";
        options.path = pkgs.grafana-dashboards.hedgedoc;
        disableDeletion = true;
      }
    ];

    my.services.nginx.virtualHosts = [
      {
        subdomain = "notes";
        inherit (cfg) port;
      }
    ];

    webapps.apps.hedgedoc = {
      dashboard = {
        name = "Notes";
        category = "app";
        icon = "edit";
        link = "https://notes.${domain}";
      };
    };
  };
}
