{ config, ... }:
{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./disks.nix
    ./network.nix
    ./syncthing.nix
    ./services.nix
    ../../legacy/modules/docker.nix
    ../../legacy/modules/networkdecrypt.nix
    ../../legacy/modules/nix.nix
  ];

  networking.hostName = "newton";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    gnupg.sshKeyPaths = [ ];
  };

  #environment.noXlibs = true;

  networking.firewall.allowedTCPPorts = [
  ];

  system = {
    stateVersion = "22.05";
    autoUpgrade.enable = true;
  };
}
