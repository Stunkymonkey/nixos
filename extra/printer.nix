{ config, lib, pkgs, ... }:

{
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    hplip
  ];
  programs.system-config-printer.enable = true;
}
