{ config, pkgs, ... }:
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
    #jetbrains.idea-community
    qgis
    sublime3
  ];
}
