{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    #../modules/backup.nix
    ../modules/compression.nix
    ../modules/development.nix
    ../modules/docker.nix
    ../modules/networkdecrypt.nix
    ../modules/nix.nix
    ../modules/ssh.nix
    ../modules/users.nix
    ../modules/webapps/config.nix
    ../modules/webapps/homer.nix
    ../modules/webapps/jellyfin.nix
    ../modules/webapps/navidrome.nix
  ];
  networking.hostName = "newton";

  sops.defaultSopsFile = ./secrets.yaml;

  #environment.noXlibs = true;

  networking.firewall.allowedTCPPorts = [
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  #boot.loader.grub.copyKernels = true;

  services.openssh.permitRootLogin = "yes";
  users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@thinkman" ];

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
