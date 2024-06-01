# Get RSS feeds from websites that don't natively have one
{ config, lib, ... }:
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
      virtualHost = domain;
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
    };

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
