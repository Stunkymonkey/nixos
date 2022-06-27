{ config, pkgs, lib, ... }:
{
  imports = [
    ./disks.nix
    ./hardware-configuration.nix
    ../modules/3d-design.nix
    ../modules/android.nix
    ../modules/avahi.nix
    ../modules/backup.nix
    ../modules/bluetooth-audio.nix
    ../modules/clean.nix
    ../modules/compression.nix
    ../modules/desktop-default.nix
    ../modules/desktop-development.nix
    ../modules/development.nix
    ../modules/docker.nix
    ../modules/filesystem.nix
    ../modules/gaming.nix
    ../modules/hardware-base.nix
    ../modules/intel-video.nix
    ../modules/intel.nix
    ../modules/kvm.nix
    ../modules/location.nix
    ../modules/media.nix
    ../modules/meeting.nix
    ../modules/nix.nix
    ../modules/power.nix
    ../modules/presentation.nix
    ../modules/printer.nix
    ../modules/screen-sharing.nix
    ../modules/sound.nix
    ../modules/sway.nix
    ../modules/sync.nix
    ../modules/systemd-user.nix
    ../modules/systemduefi.nix
    ../modules/tex.nix
    ../modules/theme.nix
    ../modules/thunderbolt.nix
    ../modules/webcam.nix
  ];

  networking.hostName = "thinkman";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    gnupg.sshKeyPaths = [];
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Nix
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7;
  };

  system = {
    stateVersion = "22.05";
    autoUpgrade.enable = true;
  };
}
