{ config, pkgs, ... }:
{
  sops.secrets.paperless_password = { };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets.paperless_password.path;
    mediaDir = "/srv/data/docs";
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
  };
  webapps.apps.paperless = {
    dashboard = {
      name = "Paperless";
      category = "app";
      icon = "book";
      link = "https://docs.buehler.rocks";
    };
  };
}
