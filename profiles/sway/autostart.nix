{ config, lib, ... }:
let
  cfg = config.my.profiles.sway-autostart;
in
{
  options.my.profiles.sway-autostart = with lib; {
    enable = mkEnableOption "sway-autostart profile";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.lemurs = {
      enable = true;
      settings.environment_switcher.include_tty_shell = true;
    };
  };
}
