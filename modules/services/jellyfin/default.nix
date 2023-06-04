# The Free Software Media System
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.jellyfin;
  domain = config.networking.domain;
  port = 8096;
  # enable monitoring
  jellyfin-with-metrics = pkgs.jellyfin.overrideAttrs (attrs: {
    # with this patch the default setting for metrics is changed
    patches = attrs.patches ++ [ ./enable-metrics.patch ];
  });
in
{
  options.my.services.jellyfin = with lib; {
    enable = mkEnableOption "Jellyfin Media Server";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      package = jellyfin-with-metrics;
    };

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "jellyfin";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString cfg.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };
    # sadly the metrics do not contain application specific metrics, only c# -> no dashboard

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
        icon = "eye";
        link = "https://media.${domain}";
      };
    };
  };
}
