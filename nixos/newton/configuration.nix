{ config, ... }:
{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./disks.nix
    ./network.nix
    ./syncthing.nix
    ./services.nix
    #../modules/backup.nix
    ../modules/docker.nix
    ../modules/networkdecrypt.nix
    ../modules/nix.nix
    ../modules/users.nix
    #../modules/webapps/radicale.nix
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
