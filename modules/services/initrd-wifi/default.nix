{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.initrd-wifi;
in
{
  options.my.services.initrd-wifi = {
    enable = lib.mkEnableOption "Enable wifi in initrd";
    interface = lib.mkOption {
      type = lib.types.str;
      example = "wlp192s0";
      description = "Wifi interface name shown by 'ip addr'";
    };
    drivers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [ "iwlwifi" ];
      description = "Drivers needed for wifi hardware";
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      example = "/run/secret/wpa_supplicant.conf";
      description = "wpa_supplicant.conf path containing ssid info.";
    };
  };
  config = lib.mkIf cfg.enable {
    boot.initrd = {
      # crypto coprocessor and wifi modules
      availableKernelModules = [
        "ccm"
        "ctr"
        "iwlmvm"
        "iwlwifi"
      ]
      ++ cfg.drivers;

      secrets."/etc/wpa_supplicant/wpa_supplicant-${cfg.interface}.conf" = cfg.configFile;

      systemd = {
        packages = [ pkgs.wpa_supplicant ];
        initrdBin = [ pkgs.wpa_supplicant ];
        # targets.initrd.wants = [ "wpa_supplicant@${cfg.interface}.service" ];
        services."wpa_supplicant@".unitConfig.DefaultDependencies = false;

        network = {
          enable = true;
          networks."20-wlan" = {
            matchConfig.Name = cfg.interface;
            networkConfig.DHCP = "yes";
          };
        };
      };
    };
  };
}
