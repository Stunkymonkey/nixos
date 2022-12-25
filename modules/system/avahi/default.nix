# avahi related settings
{ config, inputs, lib, options, pkgs, ... }:
let
  cfg = config.my.system.avahi;
in
{
  options.my.system.avahi = with lib; {
    enable = mkEnableOption "avahi configuration";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
