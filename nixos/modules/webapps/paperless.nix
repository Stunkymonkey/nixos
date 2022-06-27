{ config, pkgs, ... }:
{
  services.paperless = {
    enable = true;
    #passwordFile = sops...
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
      link = "http://buehler.rocks:28981";
    };
  };
}
