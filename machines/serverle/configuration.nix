{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./dyndns.nix
    ./services.nix
    ./syncthing.nix
    ./wifi.nix
    #../../legacy/modules/3d-printer.nix
    ../../legacy/modules/avahi.nix
    ../../legacy/modules/docker.nix
    ../../legacy/modules/nix.nix
    ../../legacy/modules/webapps/bazarr.nix
    ../../legacy/modules/webapps/prowlarr.nix
    ../../legacy/modules/webapps/radarr.nix
    ../../legacy/modules/webapps/sonarr.nix
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
