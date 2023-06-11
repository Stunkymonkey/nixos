{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.gnome;
in
{
  options.my.profiles.gnome = with lib; {
    enable = mkEnableOption "gnome profile";
  };

  config = lib.mkIf cfg.enable {
    programs.gnome-disks.enable = true;
    services.udisks2.enable = true;

    xdg.mime.enable = true;

    # make gnome settings persistent
    programs.dconf.enable = true;

    # gnome services
    services.dbus.packages = [ pkgs.dconf ];
    services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      glib
      gnome.adwaita-icon-theme
      gnome.dconf-editor
      gnome.eog
      gnome.file-roller
      gnome.gnome-calculator
      polkit_gnome
      xdg-utils
    ];
  };
}
