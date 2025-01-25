# Dashboard site
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.homer;
  inherit (config.networking) domain;

  homeConfig = {
    title = "Dashboard";
    header = false;
    footer = false;
    connectivityCheck = true;
    columns = "auto";
    services = config.lib.webapps.homerServices;
  };
in
{
  imports = [ ./config.nix ];

  options.my.services.homer = with lib; {
    enable = mkEnableOption "Homer Dashboard";
  };

  config = lib.mkIf cfg.enable {
    # TODO: 25.05 use stable
    services.caddy.virtualHosts.${domain} = {
      extraConfig = ''
        import common
        root * ${pkgs.unstable.homer}
        file_server
        handle_path /assets/config.yml {
          root * ${pkgs.writeText "homerConfig.yml" (builtins.toJSON homeConfig)}
          file_server
        }
      '';
      useACMEHost = domain;
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
