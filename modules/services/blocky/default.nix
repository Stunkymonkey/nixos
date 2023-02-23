# Fast and lightweight DNS proxy as ad-blocker for local network
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.blocky;
  domain = config.networking.domain;
in
{
  options.my.services.blocky = with lib; {
    enable = mkEnableOption "Blocky DNS Server";

    settings = mkOption {
      type = (pkgs.formats.json { }).type;
      default = { };
      example = {
        "tlsPort" = ":853";
      };
      description = ''
        Override settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;

      settings = {
        "tlsPort" = ":853";
      } // cfg.settings;
    };
  };
}
