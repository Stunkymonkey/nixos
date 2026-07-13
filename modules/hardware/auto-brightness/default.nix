# ambient light sensor auto-brightness
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.auto-brightness;
in
{
  options.my.hardware.auto-brightness = {
    enable = lib.mkEnableOption "illuminanced ambient-light auto-brightness daemon";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.illuminanced = {
      description = "Ambient light monitoring service";
      documentation = [ "https://github.com/mikhail-m1/illuminanced" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.illuminanced}/bin/illuminanced -d -c ${./illuminanced.toml} -p /run/illuminanced.pid";
        Restart = "on-failure";
      };
    };
  };
}
