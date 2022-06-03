{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    arduino
    bless # hex editor
    chromium
    dbeaver
    filezilla
    fritzing
    gnome.gnome-font-viewer
    meld
    insomnia
    qgis
    sqlitebrowser
    unstable.sublime4
  ];
}
