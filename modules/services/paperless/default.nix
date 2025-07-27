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

    mediaDir = mkOption {
      type = types.path;
      description = "Location of the FreshRSS data.";
      example = "/data/docs";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "additional extraConfig";
    };
  };

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;
      inherit (cfg) mediaDir passwordFile;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
      }
      // cfg.settings;
    };

    # monitoring is not really useful, because it only contains the http-worker infos -> skipped for now

    my.services.webserver.virtualHosts = [
      {
        subdomain = "docs";
        inherit (config.services.paperless) port;
      }
    ];

    webapps.apps.paperless = {
      dashboard = {
        name = "Documents";
        category = "media";
        icon = "book";
        url = "https://docs.${domain}";
      };
    };
  };
}
