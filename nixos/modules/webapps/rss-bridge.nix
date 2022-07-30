{ config, pkgs, ... }:
let
  domain = "rss-bridge.buehler.rocks";
in
{
  services.rss-bridge = {
    enable = true;
    virtualHost = domain;
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
  };

  security.acme.certs.${domain} = {
    group = "nginx";
  };

  webapps.apps.rss-bridge = {
    dashboard = {
      name = "RSS-Bridge";
      category = "app";
      icon = "rss";
      link = "https://rss-bridge.buehler.rocks";
    };
  };
}
