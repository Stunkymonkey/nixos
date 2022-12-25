{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
    qgnomeplatform
  ];
  qt5.platformTheme = "qt5ct";
}
