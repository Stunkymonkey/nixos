{ config, ... }:
{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./network.nix
    ./services.nix
    ./syncthing.nix
    ./system.nix
  ];

  disko.devices = import ./disko-config.nix {
    disks = [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];
  };

  networking.hostName = "newton";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    gnupg.sshKeyPaths = [ ];
  };

  system = {
    stateVersion = "23.05";
    autoUpgrade.enable = true;
  };
}
