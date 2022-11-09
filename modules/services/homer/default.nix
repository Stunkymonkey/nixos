# Dashboard site
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.homer;
  domain = config.networking.domain;

  homeConfig = {
    title = "Dashboard";
    header = false;
    footer = false;
    connectivityCheck = true;
    colums = "auto";
    services = config.lib.webapps.homerServices;
  };
in
{
  imports = [
    ./config.nix
  ];

  options.my.services.homer = with lib; {
    enable = mkEnableOption "Homer Dashboard";
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = {
      # This is not a subdomain, cannot use my nginx wrapper module
      ${domain} = {
        forceSSL = true;
        useACMEHost = domain;
        root = pkgs.homer;
        locations."=/assets/config.yml" = {
          alias = pkgs.writeText "homerConfig.yml" (builtins.toJSON homeConfig);
        };
      };
      # redirect any other attempt to the main site
      "${domain}-redirect" = {
        forceSSL = true;
        useACMEHost = domain;
        default = true;
        globalRedirect = "${domain}";
      };
    };

    webapps = {
      dashboardCategories = [
        { name = "Applications"; tag = "app"; }
        { name = "Media"; tag = "media"; }
        { name = "Infrastructure"; tag = "infra"; }
        { name = "Other"; tag = "other"; }
      ];
    };
  };
}
