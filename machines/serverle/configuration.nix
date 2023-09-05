{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./network.nix
    ./services.nix
    ./syncthing.nix
    ./system.nix
    ./wifi.nix
  ];
  networking.hostName = "serverle";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # disable gpg and thereby enable age
    gnupg.sshKeyPaths = [ ];
  };

  system = {
    stateVersion = "23.05";
    autoUpgrade.enable = true;
  };
}
