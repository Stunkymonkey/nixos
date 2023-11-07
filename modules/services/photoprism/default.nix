# self-hosted photo gallery
{ config, lib, ... }:
let
  cfg = config.my.services.photoprism;
  domain = config.networking.domain;
in
{
  options.my.services.photoprism = {
    enable = lib.mkEnableOption (lib.mdDoc "Photoprism web server");

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = lib.mdDoc ''
        Admin password file.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2342;
      description = lib.mdDoc ''
        Web interface port.
      '';
    };

    originalsPath = lib.mkOption {
      type = lib.types.path;
      default = null;
      example = "/data/photos";
      description = lib.mdDoc ''
        Storage path of your original media files (photos and videos)
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = lib.mdDoc ''
        Extra photoprism config options. See [the getting-started guide](https://docs.photoprism.app/getting-started/config-options/) for available options.
      '';
      example = {
        PHOTOPRISM_DEFAULT_LOCALE = "de";
        PHOTOPRISM_ADMIN_USER = "root";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.photoprism = {
      enable = true;
      passwordFile = cfg.passwordFile;
      port = cfg.port;
      originalsPath = cfg.originalsPath;
      settings = cfg.settings;
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "photos";
        inherit (cfg) port;
        extraConfig = {
          locations."/" = {
            proxyWebsockets = true;
          };
        };
      }
    ];

    webapps.apps.photoprism = {
      dashboard = {
        name = "Photos";
        category = "media";
        icon = "image";
        link = "https://photos.${domain}/library/login";
        method = "get";
      };
    };
  };
}
