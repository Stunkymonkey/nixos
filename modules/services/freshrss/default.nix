# RSS aggregator and reader
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.freshrss;
  domain = config.networking.domain;
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

    baseUrl = mkOption {
      type = types.str;
      description = "Default URL for FreshRSS.";
      example = "https://freshrss.example.com";
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
      inherit (cfg) baseUrl language passwordFile defaultUser;
    };

    # Set up a Nginx virtual host.
    services.nginx = {
      virtualHosts."freshrss" = {
        serverName = "news.${domain}";
        forceSSL = true;
        useACMEHost = domain;
      };
    };

    webapps.apps.freshrss = {
      dashboard = {
        name = "News";
        category = "app";
        icon = "newspaper";
        link = "https://news.${domain}";
      };
    };
  };
}
