{ config, pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin = {
    after = [ "network-online.target" ];
    #unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  webapps.apps.jellyfin = {
    dashboard = {
      name = "Jellyfin";
      category = "app";
      icon = "film";
      link = "http://192.168.178.60:8096";
    };
  };
}
