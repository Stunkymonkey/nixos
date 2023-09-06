{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./services.nix
    ./syncthing.nix
    ./system.nix
    ./wifi.nix
  ];

  disko.devices = import ./disko-config.nix {
    disks = [ "/dev/disk/by-id/usb-Seagate_Expansion_2HC015KJ-0:0" ];
  };

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
