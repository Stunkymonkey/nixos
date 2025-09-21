# monitoring system services
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.services.node-exporter;
in
{
  options.my.services.node-exporter = {
    enable = lib.mkEnableOption "Node-Exporter for monitoring";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            "textfile"
          ];
          extraFlags = [ "--collector.textfile.directory=/etc/prometheus-node-exporter-text-files" ];
        };
        systemd = {
          enable = true;
        };
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
        {
          job_name = "systemd";
          static_configs = [
            {
              targets = [ "localhost:${toString config.services.prometheus.exporters.systemd.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };

    # inputs == flake inputs in configurations.nix
    environment.etc =
      let
        inputsWithDate = lib.filterAttrs (_: input: input ? lastModified) inputs;
        flakeAttrs =
          input:
          (lib.mapAttrsToList (n: v: ''${n}="${v}"'') (
            lib.filterAttrs (_n: v: (builtins.typeOf v) == "string") input
          ));
        lastModified =
          name: input:
          ''flake_input_last_modified{input="${name}",${lib.concatStringsSep "," (flakeAttrs input)}} ${toString input.lastModified}'';
      in
      {
        "prometheus-node-exporter-text-files/flake-inputs.prom" = {
          mode = "0555";
          text = ''
            # HELP flake_registry_last_modified Last modification date of flake input in unixtime
            # TYPE flake_input_last_modified gauge
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList lastModified inputsWithDate)}
          '';
        };
      };

    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Node Exporter";
          options.path = pkgs.grafana-dashboards.node-exporter;
          disableDeletion = true;
        }
        {
          name = "Systemd";
          options.path = pkgs.grafana-dashboards.node-systemd;
          disableDeletion = true;
        }
      ];
    };

    my.services.prometheus.rules = {
      nixpkgs_out_of_date = {
        condition = ''(time() - flake_input_last_modified{input="nixpkgs"}) / (60 * 60 * 24) > 14'';
        description = "{{$labels.host}}: nixpkgs flake is older than two weeks";
      };
      # disk space
      filesystem_full_shortly = {
        condition = "predict_linear(node_filesystem_free[1h], (4 * 60 * 60)) < 0";
        time = "5m";
        description = "Disk would fill up in 4 hours. Please check the disk space";
        labels = {
          severity = "page";
        };
      };
      filesystem_almost_full = {
        condition = ''100 - ((node_filesystem_avail_bytes{fstype!~"tmpfs|ramfs",mountpoint!="/nix/store"} * 100) / node_filesystem_size_bytes{fstype!~"tmpfs|ramfs",mountpoint!="/nix/store"}) >= 90'';
        time = "10m";
        description = "{{$labels.instance}} device {{$labels.device}} on {{$labels.path}} got less than 10% space left on its filesystem";
      };
      filesystem_inodes_full = {
        condition = ''node_filesystem_files_free / node_filesystem_files < 0.10'';
        time = "10m";
        description = "{{$labels.instance}} device {{$labels.device}} on {{$labels.path}} got less than 10% inodes left on its filesystem";
      };
      # disk errors
      filesystem_errors = {
        condition = ''node_filesystem_device_error{fstype!~"tmpfs|ramfs"} > 0'';
        description = "{{$labels.instance}}: filesystem has reported {{$value}} errors: check /sys/fs/ext4/*/errors_count";
      };
      disk_unusual_read = {
        condition = ''sum by (instance) (rate(node_disk_read_bytes_total[2m])) / 1024 / 1024 > 50'';
        description = ''Disk is probably reading too much data (> 50 MB/s)\n  VALUE = {{ $value }}'';
      };
      disk_unusual_write = {
        condition = ''sum by (instance) (rate(node_disk_written_bytes_total[2m])) / 1024 / 1024 > 50'';
        description = ''Disk is probably writing too much data (> 50 MB/s)\n  VALUE = {{ $value }}'';
      };
      # memory
      ram_almost_full = {
        condition = "node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10";
        time = "1h";
        description = ''Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}'';
      };
      load_high = {
        condition = ''100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80'';
        time = "0m";
        description = ''CPU load is > 80%\n  VALUE = {{ $value }}'';
      };
      swap_is_filling = {
        condition = ''(1 - (node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes)) * 100 > 80'';
        description = "{{$labels.host}} is using {{$value}} (>80%) of its swap space";
      };
      oom_kill_detected = {
        condition = ''increase(node_vmstat_oom_kill[1m]) > 0'';
        description = ''OOM kill detected\n  VALUE = {{ $value }}'';
        time = "0m";
      };
      # network
      network_unusual_throughput_in = {
        condition = ''sum by (instance) (rate(node_network_receive_bytes_total[2m])) / 1024 / 1024 > 100'';
        description = ''Host network interfaces are probably receiving too much data (> 100 MB/s)\n  VALUE = {{ $value }}'';
      };
      network_unusual_throughput_out = {
        condition = ''sum by (instance) (rate(node_network_transmit_bytes_total[2m])) / 1024 / 1024 > 100'';
        description = ''Host network interfaces are probably sending too much data (> 100 MB/s)\n  VALUE = {{ $value }}'';
      };
      # uptime
      reboot = {
        condition = "node_time_seconds - node_boot_time_seconds < (5 * 30)";
        description = "{{$labels.host}} just rebooted";
      };
      uptime = {
        condition = ''node_time_seconds - node_boot_time_seconds > (30 * 24 * 60 * 60)'';
        description = "Uptime monster: {{$labels.host}} has been up for more than 30 days";
      };
      # systemd
      systemd_unit_crashed = {
        # ignore user services
        condition = ''node_systemd_unit_state{state="failed", name!~"user@\\d+.service"} == 1'';
        description = "Host SystemD service crashed (instance {{ $labels.instance }})";
      };
      # time
      clock_not_synchronising = {
        condition = ''min_over_time(node_timex_sync_status[1m]) == 0 and node_timex_maxerror_seconds >= 16'';
        description = ''Clock not synchronising.\n  VALUE = {{ $value }}'';
      };
    };
  };
}
