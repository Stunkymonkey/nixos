{ config, lib, pkgs, ... }:
let
  borgbackupPath = "u181505-sub1@u181505-sub1.your-storagebox.de";
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

  sops.secrets."borgbackup/password" = { };
  sops.secrets."borgbackup/private_ssh_key" = { };

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
      "/tmp"
      "/var/lock"
      "/var/lib/docker/devicemapper"
      "/var/run"
      "/var/tmp"
      "/srv/data/tmp"
      "/srv/data/todo"
      "/home/*/.gvfs"
      "/home/*/tmp"
      "/home/*/todo"
      "sh:/home/*/.cache"
      "sh:/home/*/.local/share/Trash"
      "sh:/home/*/.thumbnails"
    ];
    extraCreateArgs = "--exclude-caches --keep-exclude-tags --stats";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets."borgbackup/password".path}";
    };
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${config.sops.secrets."borgbackup/private_ssh_key".path} -p 23";
    repo = borgbackupPath + ":${config.networking.hostName}/";
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
