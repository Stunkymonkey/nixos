{ config, lib, pkgs, ... }:
let
  cfg = import ../vars-dyndns.nix;
in
{
  services.ddclient = {
    enable = true;
    server = cfg.dyndns.server;
    username = cfg.dyndns.username;
    passwordFile = "/root/.dyndns_password";
    domains = cfg.dyndns.domains;
    ipv6 = true;
  };
}
