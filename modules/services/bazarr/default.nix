# manages and downloads subtitles
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.bazarr;
  domain = config.networking.domain;
  port = 6767;
in
{
  options.my.services.bazarr = with lib; {
    enable = mkEnableOption "Bazarr for subtitle management";
  };

  config = lib.mkIf cfg.enable {
    services.bazarr = {
      enable = true;
    };

    systemd.services.bazarr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "subtitles";
        inherit port;
      }
    ];

    my.services.exportarr.bazarr = {
      port = port + 1;
      url = "http://127.0.0.1:${toString port}";
    };

    webapps.apps.bazarr = {
      dashboard = {
        name = "Subtitles";
        category = "app";
        icon = "closed-captioning";
        link = "https://subtitles.${domain}";
      };
    };
  };
}
