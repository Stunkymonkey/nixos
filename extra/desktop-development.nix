{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    arduino
    bless # hex editor
    chromium
    dbeaver
    filezilla
    fritzing
    gnome3.meld
    insomnia
    qgis
    unstable.sublime4
  ];
}
