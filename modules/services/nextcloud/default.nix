# self-hosted cloud
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.nextcloud;
  inherit (config.networking) domain;
in
{
  options.my.services.nextcloud = with lib; {
    enable = mkEnableOption "Nextcloud";
    maxSize = mkOption {
      type = types.str;
      default = "10G";
      example = "512M";
      description = "Maximum file upload size";
    };
    admin = mkOption {
      type = types.str;
      default = "felix";
      example = "admin";
      description = "Name of the admin user";
    };
    default_phone_region = mkOption {
      type = types.str;
      default = "DE";
      example = "US";
      description = "country codes for automatic phone-number ";
    };
    passwordFile = mkOption {
      type = types.path;
      example = "/var/lib/nextcloud/password.txt";
      description = ''
        Path to a file containing the admin's password, must be readable by
        'nextcloud' user.
      '';
    };

    exporterPasswordFile = mkOption {
      type = types.path;
      example = "/var/lib/nextcloud/password.txt";
      description = ''
        Path to a file containing the admin's password, must be readable by
        'nextcloud' user.
      '';
    };
    exporterPort = mkOption {
      type = types.port;
      default = 9205;
      example = 8080;
      description = "Internal port for the exporter";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud30;
        hostName = "cloud.${domain}";
        maxUploadSize = cfg.maxSize;
        autoUpdateApps.enable = true;
        settings = {
          inherit (cfg) default_phone_region;
          overwriteprotocol = "https"; # nginx only allows SSL
        };
        config = {
          adminuser = cfg.admin;
          adminpassFile = cfg.passwordFile;

          #dbtype = "pgsql";
          #dbhost = "/run/postgresql";
        };

        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit
            calendar
            contacts
            tasks
            deck
            ;
        };
        extraAppsEnable = true;
      };

      #postgresql = {
      #  enable = true;
      #  ensureDatabases = [ "nextcloud" ];
      #  ensureUsers = [
      #    {
      #      name = "nextcloud";
      #      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      #    }
      #  ];
      #};

      prometheus.exporters.nextcloud = {
        enable = true;
        url = "https://cloud.${domain}";
        username = cfg.admin;
        passwordFile = cfg.exporterPasswordFile;
        port = cfg.exporterPort;
      };

      prometheus.scrapeConfigs = [
        {
          job_name = "nextcloud";
          static_configs = [
            {
              targets = [ "localhost:${toString cfg.exporterPort}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
      grafana.provision = {
        dashboards.settings.providers = [
          {
            name = "Nextcloud";
            options.path = pkgs.grafana-dashboards.nextcloud;
            disableDeletion = true;
          }
        ];
      };
    };

    #systemd.services."nextcloud-setup" = {
    #  requires = [ "postgresql.service" ];
    #  after = [ "postgresql.service" ];
    #};
    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };

    users.groups.nextcloud.members = [
      "nextcloud"
      config.services.caddy.user
    ];

    my.services.webserver.virtualHosts = [
      {
        subdomain = "cloud";
        extraConfig = ''
          redir /.well-known/carddav /remote.php/dav/ 301
          redir /.well-known/caldav /remote.php/dav/ 301

          @forbidden {
              path /.htaccess
              path /data/*
              path /config/*
              path /db_structure
              path /.xml
              path /README
              path /3rdparty/*
              path /lib/*
              path /templates/*
              path /occ
              path /console.php
          }
          respond @forbidden 403

          header {
            X-Frame-Options "sameorigin"
            X-Permitted-Cross-Domain-Policies "none"
          }

          # TODO: `config.services.nextcloud.package` does not contain additional apps. in nixpkgs there is "nextcloud-with-apps".
          # for now we use the path passed to nginx. Can be improved in 25.05 via: https://github.com/NixOS/nixpkgs/pull/376818
          root * ${config.services.nginx.virtualHosts."cloud.${domain}".root}
          file_server
          php_fastcgi unix/${config.services.phpfpm.pools."nextcloud".socket} {
            root ${config.services.nginx.virtualHosts."cloud.${domain}".root}
            env front_controller_active true
            env modHeadersAvailable true
          }
        '';
      }
    ];

    my.services.backup = {
      exclude = [
        # image previews can take up a lot of space
        "${config.services.nextcloud.home}/data/appdata_*/preview"
      ];
    };

    webapps.apps.nextcloud = {
      dashboard = {
        name = "Cloud";
        category = "media";
        icon = "cloud";
        url = "https://cloud.${domain}/login";
      };
    };
  };
}
