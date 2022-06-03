{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    config.boot.kernelPackages.cpupower
    pkgs.powertop
    pkgs.s-tui
  ];

  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "powersave";
    #powertop.enable = true; # messes up usb mouse
  };

  services = {
    thermald.enable = true;
    upower.enable = true;
  };
}
