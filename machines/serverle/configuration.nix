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

  # Nix
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  system = {
    stateVersion = "23.05";
    autoUpgrade.enable = true;
  };
}
