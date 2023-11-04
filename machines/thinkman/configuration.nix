{ config, pkgs, lib, ... }:
{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./network.nix
    ./profiles.nix
    ./services.nix
    ./system.nix
    ./disko-config.nix
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
