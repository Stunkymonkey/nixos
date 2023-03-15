{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./dyndns.nix
    ./network.nix
    ./services.nix
    ./syncthing.nix
    ./system.nix
    ./wifi.nix
    ../../legacy/modules/webapps/bazarr.nix
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
    stateVersion = "22.11";
    autoUpgrade.enable = true;
  };
}
