# avahi related settings
{
  config,
  lib,
  options,
  ...
}:
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
