{ config, pkgs, lib, ... }:
{
  imports = [
    ./backup.nix
    ./core.nix
    ./default.nix
    ./disks.nix
    ./disks-home.nix
    ./sway.nix
    ./extra/3d-printing.nix
    ./extra/android.nix
    ./extra/arch-linux.nix
    ./extra/avahi.nix
    ./extra/bluetooth-audio.nix
    ./extra/clean.nix
    ./extra/default.nix
    ./extra/desktop-development.nix
    ./extra/development.nix
    ./extra/docker.nix
    ./extra/filesystem.nix
    ./extra/gaming.nix
    ./extra/hardware-base.nix
    ./extra/intel-video.nix
    ./extra/intel.nix
    ./extra/kvm.nix
    ./extra/location.nix
    ./extra/media.nix
    ./extra/meeting.nix
    ./extra/nix.nix
    ./extra/power.nix
    ./extra/presentation.nix
    ./extra/printer.nix
    ./extra/screen-sharing.nix
    ./extra/sound.nix
    ./extra/sync.nix
    ./extra/systemd-user.nix
    ./extra/systemduefi.nix
    ./extra/tex.nix
    ./extra/theme.nix
    ./extra/thunderbolt.nix
    ./extra/webcam.nix
    ./hardware/t14.nix
  ];

  networking.hostName = "thinkman";

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Nix
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  system.stateVersion = "20.09";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-20.09;
}
