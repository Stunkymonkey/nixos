# Dashboard site
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.homer;
  inherit (config.networking) domain;

  homeConfig = {
    header = false;
    footer = false;
    columns = "auto";
    services = config.lib.webapps.homerServices;
  };
in
{
  imports = [ ./config.nix ];

  options.my.services.homer = {
    enable = lib.mkEnableOption "Homer Dashboard";
  };

  config = lib.mkIf cfg.enable {
    services.homer = {
      enable = true;
      virtualHost.caddy.enable = true;
      virtualHost.domain = domain;
      settings = homeConfig;
    };

    webapps = {
      dashboardCategories = [
        {
          name = "Applications";
          tag = "app";
        }
        {
          name = "Media";
          tag = "media";
        }
        {
          name = "Infrastructure";
          tag = "infra";
        }
        {
          name = "Others";
          tag = "other";
        }
      ];
    };
  };
}
