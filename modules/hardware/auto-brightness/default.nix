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
  # keep in sync with illuminanced.toml
  backlight = "/sys/class/backlight/amdgpu_bl1";
in
{
  options.my.hardware.auto-brightness = {
    enable = lib.mkEnableOption "illuminanced ambient-light auto-brightness daemon";

    onBatteryOnly = lib.mkEnableOption "auto-brightness only while running on battery";
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services = {
        illuminanced = {
          description = "Ambient light monitoring service";
          documentation = [ "https://github.com/mikhail-m1/illuminanced" ];
          wantedBy = [ (if cfg.onBatteryOnly then "battery.target" else "multi-user.target") ];
          partOf = lib.optional cfg.onBatteryOnly "battery.target";
          # -d (no-fork) hard-codes DEBUG logging to stdout, so let it fork and
          # log to syslog at the configured log_level instead.
          serviceConfig = {
            Type = "forking";
            PIDFile = "/run/illuminanced.pid";
            ExecStart = "${pkgs.illuminanced}/bin/illuminanced -c ${./illuminanced.toml}";
            Restart = "on-failure";
          };
        };

        # illuminanced leaves the backlight wherever it was, so go to full brightness on AC.
        ac-max-brightness = lib.mkIf cfg.onBatteryOnly {
          description = "Full backlight brightness on AC power";
          wantedBy = [ "ac.target" ];
          partOf = [ "ac.target" ];
          after = [ "illuminanced.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            cat ${backlight}/max_brightness > ${backlight}/brightness
          '';
        };
      };

      # AC/battery power state as systemd targets, driven by udev.
      targets = lib.mkIf cfg.onBatteryOnly {
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
    };

    services.udev.extraRules = lib.mkIf cfg.onBatteryOnly ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${systemctl} --no-block start battery.target"
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${systemctl} --no-block start ac.target"
    '';
  };
}
