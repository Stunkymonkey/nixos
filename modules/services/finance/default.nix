# finance overview
{ config, lib, ... }:
let
  cfg = config.my.services.finance;
  inherit (config.networking) domain;
in
{
  options.my.services.finance = with lib; {
    enable = lib.mkEnableOption "Finance firefly service.";

    appKeyFile = mkOption {
      type = types.path;
      description = "appkey for the service.";
      example = "/run/secrets/freshrss";
      default = "base64:ICs6jizTJnu4U8Sl/+GKIUC6TSK+0i+Lu84CicRhTNE=";
    };
  };

  config = lib.mkIf cfg.enable {
    services.firefly-iii = {
      enable = true;
      virtualHost = "finance";
      enableNginx = true;
      settings = {
        APP_KEY_FILE = cfg.appKeyFile;
        SITE_OWNER = "server@buehler.rocks";
      };
    };

    services.nginx.virtualHosts."finance" = {
      serverName = "finance.${domain}";
      forceSSL = true;
      useACMEHost = domain;
    };

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
