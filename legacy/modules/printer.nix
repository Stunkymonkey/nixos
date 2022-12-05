{ config, lib, pkgs, ... }:

{
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    canon-cups-ufr2
    gutenprint
    hplip
  ];
  programs.system-config-printer.enable = true;
}
