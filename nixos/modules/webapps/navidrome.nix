{ config, pkgs, ... }:
{
  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/srv/data/music";
    };
  };
  networking.firewall.allowedTCPPorts = [ 4533 ];

  systemd.services.navidrome = {
    after = [ "network-online.target" ];
    #unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  webapps.apps.navidrome = {
    dashboard = {
      name = "Navidrome";
      category = "media";
      icon = "music";
      link = "https://music.buehler.rocks";
    };
  };
}
