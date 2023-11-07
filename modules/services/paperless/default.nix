# document management system
{ config, lib, ... }:
let
  cfg = config.my.services.paperless;
  inherit (config.networking) domain;
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

    mediaDir = mkOption {
      type = types.path;
      description = "Password for the defaultUser for FreshRSS.";
      example = "/run/secrets/freshrss";
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
      inherit (cfg) port mediaDir;
      extraConfig = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
      } // cfg.extraConfig;
    };

    # monitoring is not really usefull, because it only contains the http-worker infos -> skipped for now

    my.services.nginx.virtualHosts = [
      {
        subdomain = "docs";
        inherit (cfg) port;
      }
    ];

    webapps.apps.paperless = {
      dashboard = {
        name = "Documents";
        category = "media";
        icon = "book";
        link = "https://docs.${domain}";
      };
    };
  };
}
