{ config, lib, ... }:
let
  cfg = config.my.hardware.drive-monitor;
in
{
  options.my.hardware.drive-monitor = with lib; {
    enable = mkEnableOption "drive-monitor configuration";

    OnFailureMail = mkOption {
      type = types.nullOr (types.str);
      description = lib.mdDoc "Mail address where to send the error report";
      default = null;
      example = "alarm@mail.com";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      postfix.enable = lib.mkIf (cfg.OnFailureMail != null) true;
      smartd = {
        enable = true;
        notifications.mail = lib.mkIf (cfg.OnFailureMail != null) {
          enable = true;
          recipient = cfg.OnFailureMail;
        };
      };
    };

    # monitoring
    services.prometheus.exporters.smartctl.enable = config.services.prometheus.enable;
    services.prometheus.scrapeConfigs = [
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }
        ];
      }
    ];
  };
}
