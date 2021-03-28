{ config, ... }:
{
  imports = [
    ./default.nix
    ./core.nix
    ./disks.nix
    ./disks-srv.nix
    ./users.nix
    ./extra/networkdecrypt.nix
    ./extra/development.nix
    ./extra/3d-printer.nix
    ./extra/ssh.nix
    ./extra/avahi.nix
    ./hardware/raspberrypi4.nix
  ];
  networking.hostName = "serverle";

  #environment.noXlibs = true;

  # Nix
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  system.stateVersion = "20.09";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-20.09;
}
