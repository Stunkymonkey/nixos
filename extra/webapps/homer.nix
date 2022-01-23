{ config, lib, pkgs, ... }:

let
  homer = pkgs.stdenv.mkDerivation rec {
    pname = "homer";
    version = "21.09.2";

    src = pkgs.fetchurl {
      urls = [
        "https://github.com/bastienwirtz/${pname}/releases/download/v${version}/${pname}.zip"
      ];
      sha256 = "sha256-NHvH3IW05O1YvPp0KOUU0ajZsuh7BMgqUTJvMwbc+qY=";
    };
    nativeBuildInputs = [ pkgs.unzip ];

    dontInstall = true;
    sourceRoot = ".";
    unpackCmd = "${pkgs.unzip}/bin/unzip -d $out $curSrc";
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
