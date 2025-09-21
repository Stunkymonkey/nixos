# finance overview
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.finance;
  inherit (config.networking) domain;
in
{
  options.my.services.finance = {
    enable = lib.mkEnableOption "Finance firefly service.";

    appKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "appkey for the service.";
      example = "/run/secrets/freshrss";
      default = "base64:ICs6jizTJnu4U8Sl/+GKIUC6TSK+0i+Lu84CicRhTNE=";
    };
  };

  config = lib.mkIf cfg.enable {
    services.firefly-iii = {
      enable = true;
      virtualHost = "finance";
      user = "caddy";
      group = "caddy";
      settings = {
        APP_KEY_FILE = cfg.appKeyFile;
        SITE_OWNER = "server@buehler.rocks";
      };
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "finance";
        extraConfig = ''
          file_server
          root * "${config.services.firefly-iii.package}/public"
          php_fastcgi unix/${config.services.phpfpm.pools."firefly-iii".socket} {
            env modHeadersAvailable true
          }
        '';
      }
    ];

    webapps.apps.finance = {
      dashboard = {
        name = "Finance";
        category = "app";
        icon = "coins";
        url = "https://finance.${domain}";
      };
    };
  };
}
