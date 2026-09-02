# ambient light sensor auto-brightness
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.auto-brightness;
  systemctl = "${config.systemd.package}/bin/systemctl";
in
{
  options.my.hardware.auto-brightness = {
    enable = lib.mkEnableOption "illuminanced ambient-light auto-brightness daemon";

    onBatteryOnly = lib.mkEnableOption "auto-brightness only while running on battery";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.illuminanced = {
      description = "Ambient light monitoring service";
      documentation = [ "https://github.com/mikhail-m1/illuminanced" ];
      wantedBy = [ (if cfg.onBatteryOnly then "battery.target" else "multi-user.target") ];
      partOf = lib.optional cfg.onBatteryOnly "battery.target";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.illuminanced}/bin/illuminanced -d -c ${./illuminanced.toml} -p /run/illuminanced.pid";
        Restart = "on-failure";
      };
    };

    # AC/battery power state as systemd targets, driven by udev.
    systemd.targets = lib.mkIf cfg.onBatteryOnly {
      ac = {
        description = "On AC power";
        conflicts = [ "battery.target" ];
        unitConfig.DefaultDependencies = false;
      };
      battery = {
        description = "On battery power";
        conflicts = [ "ac.target" ];
        unitConfig.DefaultDependencies = false;
      };
    };

    services.udev.extraRules = lib.mkIf cfg.onBatteryOnly ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${systemctl} --no-block start battery.target"
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${systemctl} --no-block start ac.target"
    '';
  };
}
