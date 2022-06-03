{ config, pkgs, ... }:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.sonarr = {
    after = [ "network-online.target" ];
    #unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  webapps.apps.sonarr = {
    dashboard = {
      name = "Sonarr";
      category = "manag";
      icon = "tv";
      link = "http://192.168.178.60:8989";
    };
  };
}
