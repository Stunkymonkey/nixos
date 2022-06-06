{ config, lib, pkgs, ... }:
let
  borgbackupPath = "u181505-sub1@u181505-sub1.your-storagebox.de:thinkman/";
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
      }
    );
  };

in
{
  # notification
  imports = [
    borgbackupMonitor
  ];

  sops.secrets.borgbackup_password = { };
  sops.secrets.borgbackup_private_ssh_key = { };

  services.borgbackup.jobs.hetzner = {
    paths = [
      "/"
    ];
    exclude = [
      "/nix"
      "/sys"
      "/run"
      "/proc"
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
      passCommand = "cat ${config.sops.secrets.borgbackup_password.path}";
    };
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${config.sops.secrets.borgbackup_private_ssh_key.path} -p 23";
    repo = borgbackupPath;
    compression = "auto,zstd";
    doInit = false;
    startAt = "daily";
    persistentTimer = true;
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
