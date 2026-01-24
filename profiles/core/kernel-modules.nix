{ config, lib, ... }:
let
  cfg = config.my.profiles.core.kernel-modules;
in
{
  options.my.profiles.core.kernel-modules.enable = lib.mkEnableOption "kernel module profile";

  config = lib.mkIf cfg.enable {
    boot.initrd.availableKernelModules = [
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
  };
}
