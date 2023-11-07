# self-hosted cloud
{ config, lib, pkgs, ... }:
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
      package = pkgs.nextcloud27;
      hostName = "cloud.${domain}";
      maxUploadSize = cfg.maxSize;
      autoUpdateApps.enable = true;
      config = {
        adminuser = cfg.admin;
        adminpassFile = cfg.passwordFile;
        inherit (cfg) defaultPhoneRegion;

        overwriteProtocol = "https"; # Nginx only allows SSL

        #dbtype = "pgsql";
        #dbhost = "/run/postgresql";
      };

      extraApps = {
        calendar = let version = "4.5.2"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/calendar/releases/download/v${version}/calendar-v${version}.tar.gz";
          sha256 = "sha256-n7GjgAyw2SLoZTEfakmI3IllWUk6o1MF89Zt3WGhR6A=";
        };
        contacts = let version = "5.4.2"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/contacts/releases/download/v${version}/contacts-v${version}.tar.gz";
          sha256 = "sha256-IkKHJ3MY/UPZqa4H86WGOEOypffMIHyJ9WvMqkq/4t8=";
        };
        tasks = let version = "0.15.0"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud/tasks/releases/download/v${version}/tasks.tar.gz";
          sha256 = "sha256-zMMqtEWiXmhB1C2IeWk8hgP7eacaXLkT7Tgi4NK6PCg=";
        };
        deck = let version = "1.11.0"; in pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud/deck/releases/download/v${version}/deck.tar.gz";
          sha256 = "sha256-stb9057pP8WXIhztNl7H8ymLqSZzSulgKgB2cbib2pQ=";
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
