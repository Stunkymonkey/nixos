{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aircrack-ng
    lynis
  ];
}
