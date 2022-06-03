{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./backup.nix
    ../modules/3d-printer.nix
    ../modules/avahi.nix
    ../modules/compression.nix
    ../modules/development.nix
    ../modules/docker.nix
    ./dyndns.nix
    ../modules/networkdecrypt.nix
    ../modules/nix.nix
    ../modules/ssh.nix
    ../modules/webapps/config.nix
    ../modules/webapps/bazarr.nix
    ../modules/webapps/homer.nix
    ../modules/webapps/jellyfin.nix
    ../modules/webapps/navidrome.nix
    ../modules/webapps/prowlarr.nix
    ../modules/webapps/radarr.nix
    ../modules/webapps/sonarr.nix
  ];
  networking.hostName = "serverle";

  sops.defaultSopsFile = ./secrets.yaml;

  #environment.noXlibs = true;

  networking.firewall.allowedTCPPorts = [
    8080 # aria
  ];

  # Nix
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  system = {
    stateVersion = "21.11";
    autoUpgrade.enable = true;
  };
}
