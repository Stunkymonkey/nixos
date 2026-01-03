{ config, lib, ... }:
let
  cfg = config.my.profiles.sway-autostart;
in
{
  options.my.profiles.sway-autostart = with lib; {
    enable = mkEnableOption "sway-autostart profile";
  };

  config = lib.mkIf cfg.enable {

    # start sway if login happens
    environment.interactiveShellInit = ''
      if test `tty` = /dev/tty1; then
        exec sway
      fi
    '';
  };
}
