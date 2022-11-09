# self-hosted git service
{ config, lib, ... }:
let
  cfg = config.my.services.gitea;
  domain = config.networking.domain;
in
{
  options.my.services.gitea = with lib; {
    enable = mkEnableOption "Gitea";
    port = mkOption {
      type = types.port;
      default = 3042;
      example = 8080;
      description = "Internal port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;
      httpPort = cfg.port;
      log.level = "Warn";
      disableRegistration = true;
      cookieSecure = true;
      settings = {
        ui.DEFAULT_THEME = "arc-green";
      };
      lfs.enable = true;
    };

    # Proxy to Gitea
    my.services.nginx.virtualHosts = [
      {
        subdomain = "git";
        inherit (cfg) port;
      }
    ];

    #my.services.backup = {
    #  paths = [
    #    config.services.gitea.lfs.contentDir
    #    config.services.gitea.repositoryRoot
    #  ];
    #};

    webapps.apps.gitea = {
      dashboard = {
        name = "Git";
        category = "app";
        icon = "git";
        link = "https://git.${domain}";
      };
    };
  };
}
