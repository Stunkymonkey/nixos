# HedgeDoc is an open-source, web-based, self-hosted, collaborative markdown editor.
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.hedgedoc;
  domain = config.networking.domain;
in
{
  options.my.services.hedgedoc = with lib; {
    enable = mkEnableOption "Navidrome Music Server";

    settings = mkOption {
      type = (pkgs.formats.json { }).type;
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

    configuration = mkOption {
      type = types.attrs;
      default = { };
      description = "additional configurations";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hedgedoc = {
      enable = true;

      configuration = {
        domain = "notes.${domain}";
        protocolUseSSL = true;
        db = {
          dialect = "sqlite";
          storage = "/var/lib/hedgedoc/db.hedgedoc.sqlite";
        };
      } // cfg.configuration;
    };

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
