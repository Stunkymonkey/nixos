# Get RSS feeds from websites that don't natively have one
{
  config,
  lib,
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
      virtualHost = domain;
      webserver = "caddy";
    };

    services.caddy.virtualHosts."${domain}".extraConfig = lib.mkAfter ''
      import common
    '';

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
