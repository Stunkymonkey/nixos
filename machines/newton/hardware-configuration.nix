{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "sd_mod"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [
    "dm-snapshot"
  ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  my.hardware = {
    drive-monitor = {
      enable = true;
      OnFailureMail = "server@buehler.rocks";
    };
  };
}
