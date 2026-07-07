{ config, lib, ... }:
let
  cfg = config.my.hardware.drive-monitor;
in
{
  options.my.hardware.drive-monitor = {
    enable = lib.mkEnableOption "drive-monitor configuration";

    onFailureMail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Mail address where to send the error report";
      default = null;
      example = "alarm@mail.com";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      postfix.enable = cfg.onFailureMail != null;
      smartd = {
        enable = true;
        notifications.mail = lib.mkIf (cfg.onFailureMail != null) {
          enable = true;
          recipient = cfg.onFailureMail;
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
            targets = [ "localhost:${toString config.services.prometheus.exporters.smartctl.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }
        ];
      }
    ];
  };
}
