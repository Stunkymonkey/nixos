{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    powertop
    s-tui
  ];

  powerManagement = {
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  services = {
    thermald.enable = true;
    upower.enable = true;
  };
}
