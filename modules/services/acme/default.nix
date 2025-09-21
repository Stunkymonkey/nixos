# automatic certificates
{ config, lib, ... }:
let
  cfg = config.my.services.acme;
  inherit (config.networking) domain;
in
{
  options.my.services.acme = {
    enable = lib.mkEnableOption "ACME certificates";

    credentialsFile = lib.mkOption {
      type = lib.types.str;
      example = "/var/lib/acme/creds.env";
      description = ''
        INWX API key file as an 'EnvironmentFile' (see `systemd.exec(5)`)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      defaults.email = "server@buehler.rocks";
      # this is specially needed for inwx and does not work without it
      defaults.dnsResolver = "ns.inwx.de";
      acceptTerms = true;
      # Use DNS wildcard certificate
      certs = {
        "${domain}" = {
          extraDomainNames = [ "*.${domain}" ];
          dnsProvider = "inwx";
          inherit (cfg) credentialsFile;
        };
      };
    };
  };
}
