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
      default = "1G";
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
  };

  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud25;
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
        calendar = pkgs.fetchNextcloudApp rec {
          name = "calendar";
          url = "https://github.com/nextcloud-releases/calendar/releases/download/v${version}/calendar-v${version}.tar.gz";
          version = "4.1.0";
          sha256 = "sha256-K5jqDgukylIREi5f4rS2OFP33u0ytmmI5ktW8ukWCjk=";
        };
        contacts = pkgs.fetchNextcloudApp rec {
          name = "contacts";
          url = "https://github.com/nextcloud-releases/contacts/releases/download/v${version}/contacts-v${version}.tar.gz";
          version = "5.0.1";
          sha256 = "sha256-vdSw7oF2D/2r5xl0wUyOfQXp0lbgWCedIuVn9HKkFws=";
        };
        tasks = pkgs.fetchNextcloudApp rec {
          name = "tasks";
          url = "https://github.com/nextcloud/tasks/releases/download/v${version}/tasks.tar.gz";
          version = "0.14.5";
          sha256 = "sha256-/foxaKyA6u8+LeUAnu4Co2msyNNd/YKD0fJUI73zxTI=";
        };
        deck = pkgs.fetchNextcloudApp rec {
          name = "deck";
          url = "https://github.com/nextcloud/deck/releases/download/v${version}/deck.tar.gz";
          version = "1.8.2";
          sha256 = "sha256-L8mFbKUi/LSXKTWjMTGeCzdiCvEgsk7p+xMRovxrCf0=";
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

    webapps.apps.nextcloud = {
      dashboard = {
        name = "Nextcloud";
        category = "app";
        icon = "cloud";
        link = "https://cloud.${domain}/login";
      };
    };
  };
}
