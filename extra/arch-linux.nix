{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pacman
  ];
  environment.etc."makepkg.conf".source = "${pkgs.pacman}/etc/makepkg.conf";
}
