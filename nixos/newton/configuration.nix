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
    ../modules/compression.nix
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

  services.openssh.permitRootLogin = "prohibit-password";
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
