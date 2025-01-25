# a password-generator using the marokov model
{ config, lib, ... }:
let
  cfg = config.my.services.passworts;
  inherit (config.networking) domain;
in
{
  options.my.services.passworts = with lib; {
    enable = mkEnableOption "Navidrome Music Server";
    port = mkOption {
      type = types.port;
      default = 5010;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.passworts = {
      enable = true;
      inherit (cfg) port;
    };

    my.services.webserver.virtualHosts = [
      {
        subdomain = "passworts";
        inherit (cfg) port;
      }
    ];

    webapps.apps.passworts = {
      dashboard = {
        name = "Passworts";
        category = "other";
        icon = "lock";
        url = "https://passworts.${domain}";
      };
    };
  };
}
