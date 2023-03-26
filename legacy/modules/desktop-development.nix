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
    unstable.qgis
    sqlitebrowser
    unstable.sublime4
    vscode
  ];
}
