# Deployed services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  sops.secrets."acme/inwx" = { };
  sops.secrets."borgbackup/password" = { };
  sops.secrets."borgbackup/ssh_key" = { };
  sops.secrets."dyndns/password" = { };
  sops.secrets."sso/auth-key" = { };
  sops.secrets."sso/felix/password-hash" = { };
  sops.secrets."sso/felix/totp-secret" = { };

  # List services that you want to enable:
  my.services = {
    backup = {
      enable = true;
      OnFailureMail = "server@buehler.rocks";
      passwordFile = secrets."borgbackup/password".path;
      sshKeyFile = secrets."borgbackup/ssh_key".path;
    };

    dyndns = {
      enable = true;
      passwordFile = secrets."dyndns/password".path;
    };

    prowlarr = {
      enable = true;
    };
    radarr = {
      enable = true;
    };
    sonarr = {
      enable = true;
    };
    bazarr = {
      enable = true;
    };

    ssh-server = {
      enable = true;
    };

    jellyfin = {
      enable = true;
    };
    # Dashboard
    homer = {
      enable = true;
    };
    # Webserver
    nginx = {
      enable = true;
      acme = {
        credentialsFile = secrets."acme/inwx".path;
      };
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
  };
}
