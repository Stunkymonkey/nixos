{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.backup;
in
{
  options.my.services.backup = with lib; {
    enable = mkEnableOption (lib.mdDoc "Borgbackup Service");

    passwordFile = mkOption {
      type = types.path;
      description = lib.mdDoc "Password for the backup";
      example = "/run/secrets/password";
    };

    sshHost = mkOption {
      type = types.str;
      description = lib.mdDoc "ssh-hostname for remote access";
      default = "u181505-sub1.your-storagebox.de";
      example = "test.domain.com";
    };
    sshUser = mkOption {
      type = types.str;
      description = lib.mdDoc "ssh-user for remote access";
      default = "u181505-sub1";
      example = "max";
    };
    sshPort = mkOption {
      type = types.port;
      description = lib.mdDoc "ssh-port for remote access";
      default = 23;
      example = 22;
    };
    sshKeyFile = mkOption {
      type = types.path;
      description = lib.mdDoc "ssh-key for remote access";
      example = "/run/secrets/ssh_key";
    };

    OnFailureNotification = mkOption {
      type = types.bool;
      description = lib.mdDoc "whether to show a warning to all users or not";
      default = false;
    };
    OnFailureMail = mkOption {
      type = types.nullOr types.str;
      description = lib.mdDoc "Mail address where to send the error report";
      default = null;
      example = "alarm@mail.com";
    };

    paths = mkOption {
      type = with types; listOf str;
      description = lib.mdDoc "additional path(s) to back up";
      default = [ "/" ];
      example = [ "/home/user" ];
    };
    exclude = mkOption {
      type = with types; listOf str;
      description = lib.mdDoc "Exclude paths matching any of the given patterns. See `borg help patterns`";
      default = [ ];
      example = [
        "/home/*/.cache"
        "/tmp"
      ];
    };

    doInit = mkOption {
      type = types.bool;
      description = lib.mdDoc ''
        Run {command}`borg init` if the
        specified {option}`repo` does not exist.
        You should set this to `false`
        if the repository is located on an external drive
        that might not always be mounted.
      '';
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    # mails can only be delivered if postfix is available
    services.postfix.enable = lib.mkIf (cfg.OnFailureMail != null) true;

    services.borgbackup.jobs.hetzner = {
      # always backup everything and only define excludes
      inherit (cfg) paths;
      exclude = [
        # system
        "/nix"
        "/mnt"
        "/proc"
        "/root/.cache/"
        "/root/.config/borg/security/"
        "/run"
        "/sys"
        "/tmp"

        # other-os
        "**/.Trash" # apple
        "**/.DS_Store" # apple
        "**/$RECYCLE.BIN" # windows
        "**/System Volume Information" # windows

        # var data
        "/var/cache"
        "/var/lib/docker/devicemapper"
        "/var/lock"
        "/var/log"
        "/var/run"
        "/var/tmp"

        # home-directories
        "/home/*/.cache"
        "/home/*/.gvfs"
        "/home/*/.local/share/Trash"
        "/home/*/.thumbnails"
        "/home/*/.config/Element/Cache"

        # self-defined
        "/data/tmp"
        "/data/todo"
        "/home/*/tmp"
        "/home/*/todo"
      ] ++ cfg.exclude;

      extraCreateArgs = "--exclude-caches --keep-exclude-tags --stats";

      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${cfg.passwordFile}";
      };

      environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${cfg.sshKeyFile} -p ${toString cfg.sshPort}";
      repo = "${cfg.sshUser}@${cfg.sshHost}:${config.networking.hostName}/";

      inherit (cfg) doInit;
      compression = "auto,zstd";

      postHook =
        ''
          if (( $exitStatus > 1 )); then
        ''
        + lib.optionalString cfg.OnFailureNotification ''
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
        ''
        + lib.optionalString (cfg.OnFailureMail != null) ''
          journalctl -u borgbackup-job-hetzner.service | ${pkgs.mailutils}/bin/mail -r "Administrator<root@buehler.rocks>" -s "Backup Error" server@buehler.rocks
          echo "sent mail"
        ''
        + ''
          fi
        '';

      # for mail sending
      readWritePaths = lib.optional (cfg.OnFailureMail != null) "/var/lib/postfix/queue/maildrop/";

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

    my.services.prometheus.rules = {
      borgbackup_execution_missing = {
        condition = ''time() - systemd_timer_last_trigger_seconds{name="borgbackup-job-hetzner.timer"} >= (60 * 60 * (24 + 1))'';
        description = "{{$labels.instance}}: last backup was 25 hours ago please check.";
      };
      borgbackup_last_execution = {
        condition = ''systemd_unit_state{state="failed", name="borgbackup-job-hetzner.timer"} >= 1'';
        description = "{{$labels.instance}}: last backup was not successful please check.";
      };
    };
  };
}
