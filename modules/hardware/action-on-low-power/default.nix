# low power action
{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.action-on-low-power;
in
{
  options.my.hardware.action-on-low-power = {
    enable = lib.mkEnableOption "action on low power";

    action = lib.mkOption {
      type = lib.types.enum [
        "hibernate"
        "hybrid-sleep"
        "poweroff"
        "sleep"
        "suspend-then-hibernate"
        "suspend"
      ];
      default = "sleep";
      description = ''
        Action to take when power is low.
      '';
    };

    powerInPercent = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = ''
        Power percentage threshold to trigger the action.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="${toString cfg.powerInPercent}", RUN+="${config.systemd.package}/bin/systemctl ${cfg.action}"
    '';
  };
}
