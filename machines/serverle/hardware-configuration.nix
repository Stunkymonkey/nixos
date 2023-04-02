{ config, pkgs, lib, ... }:
{
  boot.loader = {
    raspberryPi = {
      firmwareConfig = ''
        # Disable the ACT LED.
        dtparam=act_led_trigger=none
        dtparam=act_led_activelow=off
        # Disable the PWR LED.
        # somehow this changed in firmware settings: https://github.com/raspberrypi/firmware/issues/1742
        #dtparam=pwr_led_trigger=default-on
        dtparam=pwr_led_activelow=off

        # Disable ethernet port LEDs
        dtparam=eth0_led=4
        dtparam=eth1_led=4

        # Disable SD-Card pools
        dtparam=sd_pool_once=on
      '';

      # the bootloader has to be enabled for fat systems. for ext use the other one.
      enable = true;
      version = 4;
    };
    generic-extlinux-compatible.enable = false;
  };

  # Kernel configuration
  boot.kernelParams = [ "cma=64M" "console=tty0" ];

  # Fix wifi disconnect
  networking.networkmanager.wifi.powersave = false;
}
