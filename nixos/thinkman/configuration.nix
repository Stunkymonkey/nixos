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
    ../modules/sway.nix
    ../modules/sync.nix
    ../modules/systemd-user.nix
    ../modules/systemduefi.nix
    ../modules/tex.nix
    ../modules/thunderbolt.nix
    ../modules/webcam.nix
  ];

  networking.hostName = "thinkman";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
  };

  nix.extraOptions = ''
    extra-platforms = aarch64-linux i686-linux
  '';
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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
