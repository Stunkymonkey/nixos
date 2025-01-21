# Deployed services
{ config, ... }:
let
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    "acme/inwx" = { };
    "bazarr/apikey" = { };
    "borgbackup/password" = { };
    "borgbackup/ssh_key" = { };
    "dyndns/password" = {
      owner = config.users.users.inadyn.name;
    };
    "fritzbox/password" = {
      owner = config.users.users.fritz-exporter.name;
    };
    "prowlarr/apikey" = { };
    "radarr/apikey" = { };
    "sonarr/apikey" = { };
    "sso/auth-key" = { };
    "sso/felix/password-hash" = { };
    "sso/felix/totp-secret" = { };
  };

  # List services that you want to enable:
  my.services = {
    backup = {
      enable = true;
      OnFailureMail = "server@buehler.rocks";
      passwordFile = secrets."borgbackup/password".path;
      sshKeyFile = secrets."borgbackup/ssh_key".path;
      paths = [ "/" ];
    };

    dyndns = {
      enable = true;
      passwordFile = secrets."dyndns/password".path;
    };

    # aria2 = {
    #   enable = true;
    #   downloadDir = "/data/tmp/aria2/";
    # };

    home-automation = {
      enable = true;
    };

    blocky = {
      enable = true;
    };

    prowlarr = {
      enable = true;
      apiKeyFile = secrets."prowlarr/apikey".path;
    };
    radarr = {
      enable = true;
      apiKeyFile = secrets."radarr/apikey".path;
    };
    sonarr = {
      enable = true;
      apiKeyFile = secrets."sonarr/apikey".path;
    };
    bazarr = {
      enable = true;
      apiKeyFile = secrets."bazarr/apikey".path;
    };

    ssh-server = {
      enable = true;
    };

    jellyfin = {
      enable = true;
    };
    jellyseerr = {
      enable = true;
    };
    fritzbox = {
      enable = true;
      passwordFile = secrets."fritzbox/password".path;
    };
    # Dashboard
    homer = {
      enable = true;
    };
    # Webserver
    nginx = {
      enable = true;
      sso = {
        authKeyFile = secrets."sso/auth-key".path;
        users = {
          felix = {
            passwordHashFile = secrets."sso/felix/password-hash".path;
            totpSecretFile = secrets."sso/felix/totp-secret".path;
          };
        };
        groups = {
          root = [ "felix" ];
        };
      };
    };
    acme = {
      enable = true;
      credentialsFile = secrets."acme/inwx".path;
    };
    vpn.enable = true;
  };
}
