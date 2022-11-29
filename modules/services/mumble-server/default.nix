# Have a good quality voice chat
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.mumble-server;
  domain = "voice.${config.networking.domain}";
in
{
  options.my.services.mumble-server = {
    enable = lib.mkEnableOption "RSS-Bridge service";
  };

  config = lib.mkIf cfg.enable {
    services.murmur = {
      enable = true;
      # TODO enable in 22.11
      #openFirewall = true;
      welcometext = "Welcome to the Mumble-Server!";
      sslCert = "/var/lib/acme/${domain}/fullchain.pem";
      sslKey = "/var/lib/acme/${domain}/key.pem";
    };

    services.nginx.virtualHosts.${domain}.enableACME = true;
    security.acme.certs."${domain}" = {
      group = "voice-buehler-rocks";
      postRun = ''
        if ${pkgs.systemd}/bin/systemctl is-active murmur.service; then
          ${pkgs.systemd}/bin/systemctl kill -s SIGUSR1 murmur.service
        fi
      '';
    };

    users.groups."voice-buehler-rocks".members = [ "murmur" "nginx" ];

    networking.firewall.allowedTCPPorts = [ config.services.murmur.port ];
    networking.firewall.allowedUDPPorts = [ config.services.murmur.port ];
  };
}
