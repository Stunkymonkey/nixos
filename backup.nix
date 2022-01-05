{ config, lib, pkgs, ... }:
let
  cfg = import ./vars-backup.nix;
  borgbackupMonitor = { config, pkgs, lib, ... }: with lib; {
    key = "borgbackupMonitor";
    _file = "borgbackupMonitor";
    config.systemd.services = {
      "notify-problems@" = {
        enable = true;
        serviceConfig.User = "felix";
        environment.SERVICE = "%i";
        script = ''
          export $(cat /proc/$(${pkgs.procps}/bin/pgrep -x "sway" -u "$USER")/environ |grep -z '^DBUS_SESSION_BUS_ADDRESS=')
          ${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run journalctl -u $SERVICE for details"
        '';
      };
    } // flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        unitConfig.OnFailure = "notify-problems@%i.service";
        preStart = lib.mkBefore ''
          # waiting for internet after resume-from-suspend
          until /run/wrappers/bin/ping google.com -c1 -q >/dev/null; do :; done
        '';
      }
    );

    # forces backup after boot in case server was powered off during scheduled event
    config.systemd.timers = flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        timerConfig.Persistent = true;
      }
    );
  };

in
{
  # notification
  imports = [
    borgbackupMonitor
  ];

  services.borgbackup.jobs.hetzner = {
    paths = [
      "/"
    ];
    exclude = [
      "/nix"
      "/root/.cache/"
      "**/.Trash"
      "/tmp/*"
      "/var/lock/*"
      "/var/run/*"
      "/var/tmp/*"
      "/home/*/tmp"
      "/home/*/todo"
      "/home/*/.cache"
      "/home/*/.gvfs"
      "/home/*/.thumbnails"
      "/home/*/.local/share/Trash"
      "/srv/data/tmp"
      "/srv/data/todo"
    ];
    extraCreateArgs = "--exclude-caches --keep-exclude-tags --stats";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/.borg_password";
    };
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /root/.ssh/backup_ed25519 -p 23";
    repo = "${cfg.borg.user}@${cfg.borg.host}:${cfg.borg.dir}";
    compression = "auto,zstd";
    doInit = false;
    startAt = "daily";
    prune.keep = {
      last = 1;
      within = "3d";
      daily = 7;
      weekly = 4;
      monthly = 6;
      yearly = 2;
    };
  };
}
