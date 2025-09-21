# running dyndns updates
{ config, lib, ... }:
let
  cfg = config.my.services.dyndns;
  inherit (config.networking) domain;
in
{
  options.my.services.dyndns = {
    enable = lib.mkEnableOption "Dyndns";

    username = lib.mkOption {
      type = lib.types.str;
      description = "Username for the dyndns.";
      example = "admin";
      default = "Stunkymonkey-dyndns";
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "Password for the username for dyndns.";
      example = "/run/secrets/freshrss";
    };
  };

  config = lib.mkIf cfg.enable {
    services.inadyn = {
      enable = true;
      settings.provider = {
        "default@inwx.com" = {
          inherit (cfg) username;
          include = cfg.passwordFile;
          hostname = "serverle.${domain}";
        };
      };
    };
  };
}
