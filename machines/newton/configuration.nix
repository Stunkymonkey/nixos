{ config, ... }:
{
  imports = [
    ./boot.nix
    ./disks.nix
    ./hardware-configuration.nix
    ./network.nix
    ./services.nix
    ./syncthing.nix
    ./system.nix
  ];

  networking.hostName = "newton";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    gnupg.sshKeyPaths = [ ];
  };

  system = {
    stateVersion = "22.11";
    autoUpgrade.enable = true;
  };
}
