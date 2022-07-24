{ config, pkgs, ... }:
{
  services.radicale = {
    enable = true;
  };

  webapps.apps.radicale = {
    dashboard = {
      name = "Radicale";
      category = "app";
      icon = "sync";
      link = "https://dav.buehler.rocks";
    };
  };
}
