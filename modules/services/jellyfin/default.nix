# The Free Software Media System
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.jellyfin;
  domain = config.networking.domain;
  port = 8096;
in
{
  options.my.services.jellyfin = with lib; {
    enable = mkEnableOption "Jellyfin Media Server";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "media";
        inherit port;
      }
    ];

    webapps.apps.jellyfin = {
      dashboard = {
        name = "Media";
        category = "media";
        icon = "film";
        link = "https://media.${domain}";
      };
    };
  };
}
