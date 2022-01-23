{ config, pkgs, ... }:
{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.prowlarr = {
    after = [ "network-online.target" ];
    #unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  webapps.apps.prowlarr = {
    dashboard = {
      name = "Prowlarr";
      category = "manag";
      icon = "sync-alt";
      link = "http://192.168.178.60:9696";
    };
  };
  # ugly fix for service not having a homedirectory
  users.users.prowlarr = {
    isSystemUser = true;
    home = "/var/lib/prowlarr";
    group = "prowlarr";
    uid = 61654;
  };
  users.groups.prowlarr = {
    gid = 61654;
  };
}
