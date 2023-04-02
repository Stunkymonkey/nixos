# manages indexes
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.prowlarr;
  domain = config.networking.domain;
  port = 9696;
in
{
  options.my.services.prowlarr = with lib; {
    enable = mkEnableOption "Prowlarr for indexing";
  };

  config = lib.mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
    };
    # # ugly fix for service not having a homedirectory
    # users.users.prowlarr = {
    #   isSystemUser = true;
    #   home = "/var/lib/prowlarr";
    #   group = "prowlarr";
    #   uid = 61654;
    # };
    # users.groups.prowlarr = {
    #   gid = 61654;
    # };

    systemd.services.prowlarr = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "movies";
        inherit port;
      }
    ];

    webapps.apps.prowlarr = {
      dashboard = {
        name = "Prowlarr";
        category = "media";
        icon = "sync-alt";
        link = "https://indexer.${domain}";
      };
    };
  };
}
