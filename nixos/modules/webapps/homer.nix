{ config, lib, pkgs, ... }:

with lib;

let
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
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    enable = true;
    #virtualHosts."dashboard.rocks" = {
    virtualHosts."_" = {
      default = true;
      locations = {
        "/" = {
          root = homer;
        };
        "=/assets/config.yml" = {
          alias = pkgs.writeText "homerConfig.yml" (builtins.toJSON homeConfig);
        };
      };
    };
  };
  webapps = {
    dashboardCategories = [
      { name = "Applications"; tag = "app"; }
      { name = "Media-Management"; tag = "manag"; }
      { name = "Infrastructure"; tag = "infra"; }
    ];
  };
}
