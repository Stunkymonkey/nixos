{ config, lib, pkgs, ... }:
{
  services.ddclient = {
    enable = true;
    server = "dyndns.inwx.com";
    username = "Stunkymonkey-dyndns";
    passwordFile = "/root/.dyndns_password";
    domains = [ "serverle.stunkymonkey.de" ];
    ipv6 = true;
  };
}
