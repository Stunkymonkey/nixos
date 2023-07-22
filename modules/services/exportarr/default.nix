{ config, pkgs, lib, ... }:
let
  cfg = config.my.services.exportarr;

  mkExportarrService = name: conf:
    let
      exportarrEnvironment = {
        PORT = toString conf.port;
        URL = conf.url;
      } // (
        lib.mapAttrs (_: toString) conf.environment
      );
    in
    lib.nameValuePair "exportarr-${name}" {
      description = "Exportarr Service ${name}";
      script = ''exec ${conf.package}/bin/exportarr "$@"'';
      serviceConfig = {
        Restart = "on-failure";
        User = "exportarr-${name}";
        Group = "exportarr-${name}";
        DynamicUser = true;
        StateDirectory = "exportarr-${name}";
        WorkingDirectory = "/var/lib/exportarr-${name}";
        RuntimeDirectory = "exportarr-${name}";

        CapabilityBoundingSet = "";
        LockPersonality = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged @setuid @keyring" ];
        UMask = "0066";
      } // lib.optionalAttrs (conf.port < 1024) {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
      wantedBy = [ "multi-user.target" ];
      environment = exportarrEnvironment;
    };
in
{
  meta.maintainers = with lib.maintainers; [ stunkymonkey ];

  options.my.services.exportarr = lib.mkOption {
    description = lib.mdDoc ''
      This is a Prometheus Exporter will export metrics gathered from Sonarr, Radarr, Lidarr, Prowlarr, and Readarr
    '';
    default = { };
    example = lib.literalExpression ''
      {
        "lidarr" = {
          port = 8687;
          url = "http://x.x.x.x:8686";
        }
        "sonarr" = {
          port = 9708;
          url = "http://x.x.x.x:9707";
        }
      };
    '';
    type = lib.types.attrsOf (lib.types.submodule (
      { name, config, ... }: {
        options = {
          # enable = lib.mkEnableOption "exportarr-${name}";
          port = lib.mkOption {
            type = lib.types.port;
            default = 9708;
            description = lib.mdDoc ''
              The port exportarr will listen on.
            '';
          };

          url = lib.mkOption {
            type = lib.types.str;
            default = "http://127.0.0.1";
            description = lib.mdDoc ''
              The full URL to Sonarr, Radarr, or Lidarr.
            '';
          };

          package = lib.mkPackageOptionMD pkgs "exportarr" { };

          environment = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = lib.mdDoc ''
              See [the configuration guide](https://github.com/onedr0p/exportarr#configuration) for available options.
            '';
            example = {
              API_KEY_FILE = "/run/secrets/exportarr";
              PROWLARR__BACKFILL = true;
            };
          };
        };
      }
    ));
  };

  config = lib.mkIf (cfg != { }) {
    systemd.services = lib.mapAttrs' mkExportarrService cfg;
  };
}
