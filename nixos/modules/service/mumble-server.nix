{ config, pkgs, ... }:
{
  services.murmur = {
    enable = true;
    # TODO enable in 22.11
    #openFirewall = true;
    welcometext = "Welcome to the Mumble-Server!";
    sslCert = "/var/lib/acme/voice.buehler.rocks/fullchain.pem";
    sslKey = "/var/lib/acme/voice.buehler.rocks/key.pem";
  };

  services.nginx.virtualHosts."voice.buehler.rocks".enableACME = true;
  security.acme.certs."voice.buehler.rocks" = {
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
}
