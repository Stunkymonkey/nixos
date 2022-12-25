# self-hosted photo gallery
{ config, pkgs, lib, ... }:
let
  cfg = config.my.services.photoprism;
  domain = config.networking.domain;

  env = {
    PHOTOPRISM_ORIGINALS_PATH = cfg.originalsPath;
    PHOTOPRISM_STORAGE_PATH = cfg.storagePath;
    PHOTOPRISM_IMPORT_PATH = cfg.importPath;
    PHOTOPRISM_HTTP_HOST = cfg.address;
    PHOTOPRISM_HTTP_PORT = toString cfg.port;
  } // (
    lib.mapAttrs (_: toString) cfg.extraConfig
  );

  manage =
    let
      setupEnv = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: val: "export ${name}=\"${val}\"") env);
    in
    pkgs.writeShellScript "manage" ''
      ${setupEnv}
      exec ${cfg.package}/bin/photoprism "$@"
    '';
in
{
  meta.maintainers = with lib.maintainers; [ stunkymonkey ];

  options.my.services.photoprism = with lib; {

    enable = mkEnableOption (lib.mdDoc "Photoprism web server");

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = lib.mdDoc "Admin password file.";
    };

    address = mkOption {
      type = types.str;
      default = "localhost";
      description = lib.mdDoc "Web interface address.";
    };

    port = mkOption {
      type = types.port;
      default = 2342;
      description = lib.mdDoc "Web interface port.";
    };

    originalsPath = mkOption {
      type = types.path;
      default = null;
      example = "/data/photos";
      description = lib.mdDoc "storage path of your original media files (photos and videos).";
    };

    importPath = mkOption {
      type = types.str;
      default = "import";
      description = lib.mdDoc "relative or absolute to the `originalsPath` from where the files should be imported.";
    };

    storagePath = mkOption {
      type = types.path;
      default = "/var/lib/photoprism";
      description = lib.mdDoc "location for sidecar, cache, and database files.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.photoprism;
      defaultText = literalExpression "pkgs.photoprism";
      description = lib.mdDoc "The Photoprism package to use.";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = { };
      description = lib.mdDoc ''
        Extra photoprism config options. See [the getting-stated guide](https://docs.photoprism.app/getting-started/config-options/) for available options.
      '';
      example = {
        PHOTOPRISM_DEFAULT_LOCALE = "de";
        PHOTOPRISM_ADMIN_USER = "root";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.photoprism = {
      description = "Photoprism server";

      serviceConfig = {
        Restart = "on-failure";
        User = "photoprism";
        Group = "photoprism";
        DynamicUser = true;
        StateDirectory = "photoprism";
        WorkingDirectory = "/var/lib/photoprism";
        RuntimeDirectory = "photoprism";

        LoadCredential = lib.optionalString (cfg.passwordFile != null)
          "PHOTOPRISM_ADMIN_PASSWORD:${cfg.passwordFile}";

        BindReadOnlyPaths = [
          "${config.environment.etc."ssl/certs/ca-certificates.crt".source}:/etc/ssl/certs/ca-certificates.crt"
          builtins.storeDir
          "-/etc/resolv.conf"
          "-/etc/nsswitch.conf"
          "-/etc/hosts"
          "-/etc/localtime"
        ];
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
        SystemCallFilter = [ "@system-service" "~@privileged" "@resources" "@setuid" "@keyring" ];
        UMask = "0066";
      } // lib.optionalAttrs (cfg.port < 1024) {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };

      wantedBy = [ "multi-user.target" ];
      environment = env;

      preStart = ''
        ln -sf ${manage} photoprism-manage
      '';

      # wait for easier password configuration: https://github.com/photoprism/photoprism/pull/2302
      script = ''
        ${lib.optionalString (cfg.passwordFile != null) ''
          export PHOTOPRISM_ADMIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/PHOTOPRISM_ADMIN_PASSWORD")
        ''}
        ${cfg.package}/bin/photoprism migrations run -f
        exec ${cfg.package}/bin/photoprism start
      '';
    };

    # Proxy to Photoprism
    my.services.nginx.virtualHosts = [
      {
        subdomain = "photos";
        inherit (cfg) port;
        extraConfig = {
          locations."/" = {
            proxyWebsockets = true;
          };
        };
      }
    ];

    webapps.apps.photoprism = {
      dashboard = {
        name = "Photos";
        category = "media";
        icon = "image";
        link = "https://photos.${domain}/library/login";
        method = "get";
      };
    };
  };
}
