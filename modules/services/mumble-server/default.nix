# Have a good quality voice chat
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.mumble-server;
  inherit (config.networking) domain;
in
{
  options.my.services.mumble-server = {
    enable = lib.mkEnableOption "mumble server service";
  };

  config = lib.mkIf cfg.enable {
    services.murmur = {
      enable = true;
      openFirewall = true;
      welcometext = "Welcome to the Mumble-Server!";
      sslCert = "${config.security.acme.certs.${domain}.directory}/fullchain.pem";
      sslKey = "${config.security.acme.certs.${domain}.directory}/key.pem";
    };

    # create a separate certificate for the mumble server
    security.acme = {
      certs.${domain} = {
        reloadServices = [ "murmur" ];
        group = "caddyandmurmur";
      };
    };
    users.groups.caddyandmurmur.members = [
      "caddy"
      "murmur"
    ];

    my.services = {
      acme.enable = true;
      prometheus.rules = {
        mumble_not_running = {
          condition = ''systemd_unit_state{name="murmur.service", state!="active"} > 0'';
          description = "{{$labels.host}} should have a running {{$labels.name}}";
        };
      };
    };
  };
}
