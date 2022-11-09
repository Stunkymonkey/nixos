# document management system
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.paperless;
  domain = config.networking.domain;
in
{
  options.my.services.paperless = with lib; {
    enable = mkEnableOption "Paperless Server";

    passwordFile = mkOption {
      type = types.path;
      description = "Password for the defaultUser for FreshRSS.";
      example = "/run/secrets/freshrss";
    };

    port = mkOption {
      type = types.port;
      default = 28981;
      example = 8080;
      description = "Internal port for webui";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = { };
      description = "additional extraConfig";
    };
  };

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;
      inherit (cfg) port;
      mediaDir = "/srv/data/docs";
      extraConfig = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
      } // cfg.extraConfig;
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "docs";
        inherit (cfg) port;
      }
    ];

    webapps.apps.paperless = {
      dashboard = {
        name = "Paperless";
        category = "media";
        icon = "book";
        link = "https://docs.${domain}";
      };
    };
  };
}