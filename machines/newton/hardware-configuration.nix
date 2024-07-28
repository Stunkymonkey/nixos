{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "sd_mod"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
