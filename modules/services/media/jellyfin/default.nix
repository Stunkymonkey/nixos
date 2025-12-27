# The Free Software Media System
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.jellyfin;
  inherit (config.networking) domain;
  # enable monitoring
  jellyfin-with-metrics = pkgs.jellyfin.overrideAttrs (attrs: {
    patches =
      let
        existingPatches = if attrs ? patches && builtins.isList attrs.patches then attrs.patches else [ ];
      in
      # with this patch the default setting for metrics is changed
      existingPatches ++ [ ./enable-metrics.patch ];
  });
in
{
  options.my.services.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin Media Server";
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
              targets = [ "localhost:${toString cfg.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };
    # sadly the metrics do not contain application specific metrics, only c# -> no dashboard

    my.services.webserver.virtualHosts = [
      {
        subdomain = "media";
        # jellyfin does not allow modification
        port = 8096;
      }
    ];

    webapps.apps.jellyfin = {
      dashboard = {
        name = "Media";
        category = "media";
        icon = "eye";
        url = "https://media.${domain}";
      };
    };
  };
}
