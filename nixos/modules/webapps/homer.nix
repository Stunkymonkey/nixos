{ config, lib, pkgs, ... }:

let
  homer = pkgs.stdenv.mkDerivation rec {
    pname = "homer";
    version = "22.06.1";

    src = pkgs.fetchzip {
      urls = [
        "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip"
      ];
      sha256 = "sha256-pr+0PFId1wG6tAFCdANiOaEdQoRMhOi+HfooO+X3geQ=";
      stripRoot = false;
    };

    installPhase = ''
      cp -r $src $out/
    '';
    sourceRoot = ".";
  };

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
