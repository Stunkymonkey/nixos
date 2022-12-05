{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fswebcam
    gnome.cheese
  ];
}
