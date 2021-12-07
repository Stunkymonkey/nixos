{ config, ... }:
{
  imports = [
    ./default.nix
    ./core.nix
    ./disks.nix
    ./disks-srv.nix
    ./users.nix
    ./extra/networkdecrypt.nix
    ./extra/compression.nix
    ./extra/development.nix
    ./extra/docker.nix
    ./extra/3d-printer.nix
    ./extra/ssh.nix
    ./extra/avahi.nix
    ./hardware/raspberrypi4.nix
  ];
  networking.hostName = "serverle";

  #environment.noXlibs = true;

  networking.firewall.allowedTCPPorts = [
    8080 # aria
  ];

  # Nix
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  system = {
    stateVersion = "21.11";
    autoUpgrade.enable = true;
  };
}
