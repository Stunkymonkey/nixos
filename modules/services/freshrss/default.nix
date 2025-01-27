# RSS aggregator and reader
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.freshrss;
  inherit (config.networking) domain;
in
{
  options.my.services.freshrss = with lib; {
    enable = lib.mkEnableOption "FreshRSS feed reader";

    package = mkOption {
      type = types.package;
      default = pkgs.freshrss;
      description = "Which FreshRSS package to use.";
    };

    defaultUser = mkOption {
      type = types.str;
      default = "admin";
      description = "Default username for FreshRSS.";
      example = "eva";
    };

    passwordFile = mkOption {
      type = types.path;
      description = "Password for the defaultUser for FreshRSS.";
      example = "/run/secrets/freshrss";
    };

    language = mkOption {
      type = types.str;
      default = "en";
      description = "Default language for FreshRSS.";
      example = "de";
    };
  };

  config = lib.mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      baseUrl = "https://news.${domain}";
      inherit (cfg) language passwordFile defaultUser;
      virtualHost = null;
      # TODO 25.05: Add support for custom virtualHost
      # webserver = "caddy";
    };

    services.phpfpm.pools.freshrss.settings = {
      "listen.owner" = lib.mkForce config.services.caddy.user;
      "listen.group" = lib.mkForce config.services.caddy.group;
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "news";
        extraConfig = ''
          root * ${config.services.freshrss.package}/p
          php_fastcgi unix/${config.services.phpfpm.pools.freshrss.socket} {
              env FRESHRSS_DATA_PATH ${config.services.freshrss.dataDir}
          }
          file_server
        '';
      }
    ];

    webapps.apps.freshrss = {
      dashboard = {
        name = "News";
        category = "app";
        icon = "newspaper";
        url = "https://news.${domain}";
      };
    };
  };
}
