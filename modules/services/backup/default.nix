{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.backup;
  borgbackupPath = "u181505-sub1@u181505-sub1.your-storagebox.de";
in
{
  options.my.services.backup = with lib; {
    enable = mkEnableOption "Borgbackup Service";

    passwordFile = mkOption {
      type = types.path;
      description = "Password for the backup";
      example = "/run/secrets/password";
    };
    sshKeyFile = mkOption {
      type = types.path;
      description = "ssh-key for remote access";
      example = "/run/secrets/ssh_key";
    };

    OnFailureNotification = mkOption {
      type = types.bool;
      description = "whether to show a warning to all users or not";
      default = false;
    };
    OnFailureMail = mkOption {
      type = types.nullOr (types.str);
      description = "Mail adress where to send the error report";
      default = null;
      example = "alarm@mail.com";
    };

    paths = mkOption {
      type = with types; listOf str;
      description = "additional path(s) to back up";
      default = [ "/" ];
      example = [
        "/home/user"
      ];
    };
    exclude = mkOption {
      type = with types; listOf str;
      description = "Exclude paths matching any of the given patterns. See `borg help patterns`";
      default = [ ];
      example = [
        "/home/*/.cache"
        "/tmp"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    # mails can only be delivered if postfix is available
    services.postfix.enable = cfg.OnFailureMail != null;

    services.borgbackup.jobs.hetzner = {
      # always backup everything and only define excludes
      inherit (cfg) paths;
      exclude = [
        "/nix"
        "/sys"
        "/run"
        "/proc"
        "/root/.cache/"
        "/root/.config/borg/security/"
        "**/.Trash"
        "/tmp"

        "/var/lock"
        "/var/lib/docker/devicemapper"
        "/var/run"
        "/var/tmp"

        "/srv/data/tmp"
        "/srv/data/todo"

        "/home/*/.cache"
        "/home/*/.gvfs"
        "/home/*/.local/share/Trash"
        "/home/*/.thumbnails"
        "/home/*/tmp"
        "/home/*/todo"
      ] ++ cfg.exclude;

      extraCreateArgs = "--exclude-caches --keep-exclude-tags --stats";

      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${cfg.passwordFile}";
      };

      environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${cfg.sshKeyFile} -p 23";
      repo = borgbackupPath + ":${config.networking.hostName}/";

      doInit = false;
      compression = "auto,zstd";

      postHook = ''
        if [[ $exitStatus != 0 ]]; then
      '' + lib.optionalString cfg.OnFailureNotification ''
        # iterate over all logged in users
        for user in $(users); do
          sway_pid=$(${pkgs.procps}/bin/pgrep -x "sway" -u "$user")
          if [ -n "$sway_pid" ]; then
            # set environment variables
            export $(cat /proc/$sway_pid/environ | grep -z '^DBUS_SESSION_BUS_ADDRESS=' | tr -d '\0')
            export DISPLAY=:0
            # send notification via dbus: https://wiki.archlinux.org/title/Desktop_notifications#Bash
            ${pkgs.sudo}/bin/sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,DISPLAY -u $user ${pkgs.libnotify}/bin/notify-send -u critical "BorgBackup Failed!" "Run journalctl -u borgbackup-job* for more details."
            echo "sent notification"
          fi
        done
      '' + lib.optionalString (cfg.OnFailureMail != null) ''
        journalctl -u borgbackup-job-hetzner.service | ${pkgs.mailutils}/bin/mail -r "Administrator<root@buehler.rocks>" -s "Backup Error" server@buehler.rocks
        echo "sent mail"
      '' + ''
        fi
      '';

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
  };
}
