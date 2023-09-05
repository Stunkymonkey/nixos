# to download things
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.aria2;
  domain = config.networking.domain;
in
{
  options.my.services.aria2 = with lib; {
    enable = mkEnableOption "Aria2 for downloads";

    downloadDir = mkOption {
      type = types.path;
      description = mdDoc ''
        Directory to store downloaded files.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.aria2 = {
      enable = true;
      openPorts = true;
      inherit (cfg) downloadDir;
    };

    systemd.services.aria2 = {
      after = [ "network-online.target" ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "download";
        root = "${pkgs.ariang}/share/ariang";
      }
    ];

    webapps.apps.aria2 = {
      dashboard = {
        name = "Download";
        category = "app";
        icon = "download";
        link = "https://download.${domain}";
      };
    };
  };
}
