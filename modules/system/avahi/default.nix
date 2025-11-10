# avahi related settings
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.system.avahi;
in
{
  options.my.system.avahi = {
    enable = lib.mkEnableOption "avahi configuration";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
