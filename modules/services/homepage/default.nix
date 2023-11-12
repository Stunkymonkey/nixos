# My own personal homepage
{ config, lib, inputs, ... }:
let
  cfg = config.my.services.homepage;
  inherit (config.networking) domain;
in
{
  options.my.services.homepage = with lib; {
    enable = mkEnableOption "Stunkymonkey-Hompage";
  };

  config = lib.mkIf cfg.enable {

    my.services.nginx.virtualHosts = [
      {
        subdomain = "blog";
        root = inputs.stunkymonkey.packages.${config.nixpkgs.system}.default;
      }
    ];

    webapps.apps.homepage = {
      dashboard = {
        name = "Homepage";
        category = "other";
        icon = "blog";
        url = "https://blog.${domain}";
      };
    };
  };
}
