{ config, pkgs, ... }:
{
  services.gitea = {
    enable = true;
    cookieSecure = true;
    httpPort = 3001;
    rootUrl = "https://git.buehler.rocks/";
    log.level = "Warn";
    disableRegistration = true;
    settings = {
      ui.DEFAULT_THEME = "arc-green";
    };
  };
  webapps.apps.gitea = {
    dashboard = {
      name = "Git";
      category = "app";
      icon = "git";
      link = "https://git.buehler.rocks";
    };
  };
}
