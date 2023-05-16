{ config, pkgs, ... }:
{
  sops.secrets."wifi/bismarck" = {
    path = "/etc/NetworkManager/system-connections/Bismarck WLAN.nmconnection";
  };

  # Try fix wifi disconnect
  networking.networkmanager.wifi.powersave = false;
  networking.networkmanager.wifi.scanRandMacAddress = false;

  # pragmatic fix for wifi loss
  systemd.timers."reconnect-wifi" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "reconnect-wifi.service";
    };
  };

  systemd.services."reconnect-wifi" = {
    script = ''
      set -eu

      ${pkgs.iputils.out}/bin/ping -q -w 5 -c 2 192.168.178.1 2> /dev/null

      if [ $? != 0 ]
      then
        ${pkgs.coreutils}/bin/echo "reconnect wifi"
        ${pkgs.networkmanager}/bin/nmcli connection up 'Bismarck WLAN'
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
