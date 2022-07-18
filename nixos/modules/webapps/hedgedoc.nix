{ config, pkgs, ... }:
{
  services.hedgedoc = {
    enable = true;
    configuration = {
      domain = "notes.buehler.rocks";
      protocolUseSSL = true;
      urlAddPort = false;
      db = {
        dialect = "sqlite";
        storage = "/var/lib/hedgedoc/db.hedgedoc.sqlite";
      };
    };
  };
  webapps.apps.hedgedoc = {
    dashboard = {
      name = "Hedgedoc";
      category = "app";
      icon = "edit";
      link = "https://notes.buehler.rocks";
    };
  };
}
