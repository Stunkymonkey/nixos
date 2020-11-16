{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fswebcam
    gnome3.cheese
  ];
}
