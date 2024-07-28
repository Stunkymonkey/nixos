{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.powersave;
in
{
  options.my.profiles.powersave = with lib; {
    enable = mkEnableOption "powersave profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      powertop
      s-tui
    ];

    powerManagement = {
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
    };

    services = {
      thermald.enable = true;
      upower.enable = true;
    };
  };
}
