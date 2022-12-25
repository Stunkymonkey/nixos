{ config, pkgs, lib, ... }:
{
  imports = [
    ./disks.nix
    ./hardware-configuration.nix
    ./services.nix
    ./system.nix
    ../../legacy/modules/3d-design.nix
    ../../legacy/modules/android.nix
    ../../legacy/modules/bluetooth-audio.nix
    ../../legacy/modules/clean.nix
    ../../legacy/modules/desktop-default.nix
    ../../legacy/modules/desktop-development.nix
    ../../legacy/modules/development.nix
    ../../legacy/modules/filesystem.nix
    ../../legacy/modules/gaming.nix
    ../../legacy/modules/hardware-base.nix
    ../../legacy/modules/intel-video.nix
    ../../legacy/modules/intel.nix
    ../../legacy/modules/kvm.nix
    ../../legacy/modules/location.nix
    ../../legacy/modules/media.nix
    ../../legacy/modules/meeting.nix
    ../../legacy/modules/power.nix
    ../../legacy/modules/presentation.nix
    ../../legacy/modules/printer.nix
    ../../legacy/modules/screen-sharing.nix
    ../../legacy/modules/sway.nix
    ../../legacy/modules/sync.nix
    ../../legacy/modules/systemd-user.nix
    ../../legacy/modules/systemduefi.nix
    ../../legacy/modules/tex.nix
    ../../legacy/modules/thunderbolt.nix
    ../../legacy/modules/webcam.nix
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
