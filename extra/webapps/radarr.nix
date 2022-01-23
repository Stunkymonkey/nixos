{ config, pkgs, ... }:
{
  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.radarr = {
    after = [ "network-online.target" ];
    #unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  webapps.apps.radarr = {
    dashboard = {
      name = "Radarr";
      category = "manag";
      icon = "film";
      link = "http://192.168.178.60:7878";
    };
  };
}
