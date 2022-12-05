{ config, pkgs, ... }:
{
  services.bazarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.bazarr = {
    after = [ "network-online.target" ];
    #unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  webapps.apps.bazarr = {
    dashboard = {
      name = "Bazarr";
      category = "manag";
      icon = "closed-captioning";
      link = "http://192.168.178.60:6767";
    };
  };
}
