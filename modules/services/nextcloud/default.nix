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
        package = pkgs.nextcloud29;
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

        extraApps = with pkgs.nextcloud29Packages.apps; {
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

      # The service above configures the domain, no need for my wrapper
      nginx.virtualHosts."cloud.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;

        # so homer can get the online status
        extraConfig = lib.optionalString config.my.services.homer.enable ''
          add_header Access-Control-Allow-Origin https://${domain};
        '';
      };

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
              targets = [ "127.0.0.1:${toString cfg.exporterPort}" ];
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
