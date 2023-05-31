# self-hosted cloud
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.nextcloud;
  domain = config.networking.domain;
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
    defaultPhoneRegion = mkOption {
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
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud26;
      hostName = "cloud.${domain}";
      maxUploadSize = cfg.maxSize;
      autoUpdateApps.enable = true;
      config = {
        adminuser = cfg.admin;
        adminpassFile = cfg.passwordFile;
        defaultPhoneRegion = cfg.defaultPhoneRegion;

        overwriteProtocol = "https"; # Nginx only allows SSL

        #dbtype = "pgsql";
        #dbhost = "/run/postgresql";
      };

      extraApps = {
        calendar = let version = "4.3.4"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/calendar/releases/download/v${version}/calendar-v${version}.tar.gz";
          sha256 = "sha256-O/OcUMfOGCNaeZcITX4QSXGi76MUjmCz+5PZNg2CQV4=";
        };
        contacts = let version = "5.2.0"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/contacts/releases/download/v${version}/contacts-v${version}.tar.gz";
          sha256 = "sha256-s2st8QZaLmkju5XxfwFEPonB+6jZ3wsJATW9e+qguOU=";
        };
        tasks = let version = "0.15.0"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud/tasks/releases/download/v${version}/tasks.tar.gz";
          sha256 = "sha256-zMMqtEWiXmhB1C2IeWk8hgP7eacaXLkT7Tgi4NK6PCg=";
        };
        deck = let version = "1.9.1"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud/deck/releases/download/v${version}/deck.tar.gz";
          sha256 = "sha256-88ZaPar2d9wUyelAWM7eYY3z01jtKYVkCeI+xxvttw4=";
        };
      };
    };

    #services.postgresql = {
    #  enable = true;
    #  ensureDatabases = [ "nextcloud" ];
    #  ensureUsers = [
    #    {
    #      name = "nextcloud";
    #      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    #    }
    #  ];
    #};

    #systemd.services."nextcloud-setup" = {
    #  requires = [ "postgresql.service" ];
    #  after = [ "postgresql.service" ];
    #};

    # The service above configures the domain, no need for my wrapper
    services.nginx.virtualHosts."cloud.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;

      # so homer can get the online status
      extraConfig = lib.optionalString config.my.services.homer.enable ''
        add_header Access-Control-Allow-Origin https://${domain};
      '';
    };

    my.services.backup = {
      exclude = [
        # image previews can take up a lot of space
        "${config.services.nextcloud.home}/data/appdata_*/preview"
      ];
    };

    services.prometheus.exporters.nextcloud = {
      enable = true;
      url = "https://cloud.${domain}";
      username = cfg.admin;
      passwordFile = cfg.exporterPasswordFile;
      port = cfg.exporterPort;
    };

    services.prometheus.scrapeConfigs = [
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
    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Nextcloud";
          options.path = pkgs.grafana-dashboards.nextcloud;
          disableDeletion = true;
        }
      ];
    };

    webapps.apps.nextcloud = {
      dashboard = {
        name = "Cloud";
        category = "media";
        icon = "cloud";
        link = "https://cloud.${domain}/login";
      };
    };
  };
}
