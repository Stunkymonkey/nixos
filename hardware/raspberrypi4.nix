{ config, pkgs, lib, ... }:
{
  # Boot
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.loader.raspberryPi.firmwareConfig = "
    # Disable the ACT LED.
    dtparam=act_led_trigger=none
    dtparam=act_led_activelow=off
    # Disable the PWR LED.
    dtparam=pwr_led_trigger=none
    dtparam=pwr_led_activelow=off
    
    # Disable SD-Card pools
    dtparam=sd_pool_once=on";

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = [ "cma=64M" "console=tty0" ];

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;

  #swapDevices = [{ device = "/swapfile"; size = 1024; }];
}
