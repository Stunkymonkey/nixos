{ config, pkgs, lib, ... }:
{
  imports = [
    ./boot.nix
    ./disks.nix
    ./hardware-configuration.nix
    ./services.nix
    ./profiles.nix
    ./system.nix
    ../../legacy/modules/desktop-default.nix
    ../../legacy/modules/desktop-development.nix
    ../../legacy/modules/development.nix
    ../../legacy/modules/filesystem.nix
    ../../legacy/modules/gaming.nix
    ../../legacy/modules/hardware-base.nix
    ../../legacy/modules/media.nix
    ../../legacy/modules/systemd-user.nix
    ../../legacy/modules/webcam.nix
  ];

  networking.hostName = "thinkman";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
  };

  # needed for cross-compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];


  system = {
    stateVersion = "22.11";
    autoUpgrade.enable = true;
  };
}
