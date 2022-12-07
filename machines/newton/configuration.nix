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
    ../../legacy/modules/networkdecrypt.nix
  ];

  networking.hostName = "newton";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    gnupg.sshKeyPaths = [ ];
  };

  networking.firewall.allowedTCPPorts = [
  ];

  system = {
    stateVersion = "22.05";
    autoUpgrade.enable = true;
  };
}
