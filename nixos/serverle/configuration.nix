{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./dyndns.nix
    ./services.nix
    ./syncthing.nix
    ./wifi.nix
    #../modules/3d-printer.nix
    ../modules/avahi.nix
    ../modules/docker.nix
    ../modules/nix.nix
    ../modules/webapps/bazarr.nix
    ../modules/webapps/prowlarr.nix
    ../modules/webapps/radarr.nix
    ../modules/webapps/sonarr.nix
  ];
  networking.hostName = "serverle";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # disable gpg and thereby enable age
    gnupg.sshKeyPaths = [ ];
  };

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
    stateVersion = "22.05";
    autoUpgrade.enable = true;
  };
}
