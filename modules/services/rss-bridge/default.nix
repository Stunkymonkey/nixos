# Get RSS feeds from websites that don't natively have one
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.rss-bridge;
  domain = "rss-bridge.${config.networking.domain}";
in
{
  options.my.services.rss-bridge = {
    enable = lib.mkEnableOption "RSS-Bridge service";
  };

  config = lib.mkIf cfg.enable {
    services.rss-bridge = {
      enable = true;
      config.system.enabled_bridges = [ "*" ]; # Whitelist all
      virtualHost = null;
      user = "caddy";
      group = "caddy";
      # TODO: with 25.05 this can be simplified via
      # webserver = "caddy";
    };
    my.services.webserver.virtualHosts = [
      {
        subdomain = "rss-bridge";
        extraConfig = ''
          root * ${pkgs.rss-bridge}
          php_fastcgi unix/${config.services.phpfpm.pools."rss-bridge".socket} {
            env RSSBRIDGE_fileCache_path ${config.services.rss-bridge.dataDir}/cache/
          }
          file_server
        '';
      }
    ];

    webapps.apps.rss-bridge = {
      dashboard = {
        name = "RSS-Bridge";
        category = "other";
        icon = "rss";
        url = "https://${domain}";
      };
    };
  };
}
