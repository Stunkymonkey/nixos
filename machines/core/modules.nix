{ config, lib, pkgs, ... }:

{
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
