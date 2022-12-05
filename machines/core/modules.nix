{ config, lib, pkgs, ... }:

{
  # Enable all firmware modules, so that bluetooth and wifi modules can load
  # https://github.com/NixOS/nixpkgs/issues/85377#issuecomment-616424682
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  boot.initrd = {
    availableKernelModules = [
      "ahci"
      "e1000e"
      "ehci_pci"
      "nvme"
      "sd_mod"
      "uas"
      "usbhid"
      "usb_storage"
      "xhci_pci"
    ];

    kernelModules = [
      "dm-snapshot"
      "e1000e"
      "nvme"
    ];
  };
}
