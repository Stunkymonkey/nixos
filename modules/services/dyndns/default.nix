# running dyndns updates
{ config, lib, ... }:
let
  cfg = config.my.services.dyndns;
  inherit (config.networking) domain;
in
{
  options.my.services.dyndns = with lib; {
    enable = mkEnableOption "Dyndns";

    username = mkOption {
      type = types.str;
      description = "Username for the dyndns.";
      example = "admin";
      default = "Stunkymonkey-dyndns";
    };
    passwordFile = mkOption {
      type = types.path;
      description = "Password for the username for dyndns.";
      example = "/run/secrets/freshrss";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ddclient = {
      enable = true;
      server = "dyndns.inwx.com";
      inherit (cfg) username passwordFile;
      domains = [ "serverle.${domain}" ];
    };
  };
}
