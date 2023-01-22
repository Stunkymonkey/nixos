{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
    qgnomeplatform
    numix-cursor-theme
    numix-icon-theme
    numix-icon-theme-circle
    adwaita-qt
    arc-kde-theme
    arc-theme
  ];
  qt5.platformTheme = "qt5ct";
}
