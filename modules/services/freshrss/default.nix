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
  options.my.services.freshrss = {
    enable = lib.mkEnableOption "FreshRSS feed reader";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.freshrss;
      description = "Which FreshRSS package to use.";
    };

    defaultUser = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "Default username for FreshRSS.";
      example = "eva";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "Password for the defaultUser for FreshRSS.";
      example = "/run/secrets/freshrss";
    };

    language = lib.mkOption {
      type = lib.types.str;
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
      virtualHost = "news.${domain}";
      webserver = "caddy";
    };

    services.caddy.virtualHosts."news.${domain}".extraConfig = lib.mkAfter ''
      import common
    '';

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
