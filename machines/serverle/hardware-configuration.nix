{ lib, pkgs, ... }:
{
  # U-Boot (from the firmware partition) starts systemd-boot via its UEFI
  # implementation once /boot/extlinux is gone. Unlike extlinux, systemd-boot
  # supports initrd secrets, which initrd-ssh needs for its host key.
  boot.loader = {
    generic-extlinux-compatible.enable = lib.mkForce false;
    systemd-boot = {
      enable = true;
      # keep the device tree overlays (e.g. disabled LEDs) working
      installDeviceTree = true;
    };
    efi.canTouchEfiVariables = false;
  };

  hardware = {
    deviceTree.name = "broadcom/bcm2711-rpi-4-b.dtb";
    raspberry-pi."4".leds = {
      eth.disable = true;
      act.disable = true;
      pwr.disable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
}
