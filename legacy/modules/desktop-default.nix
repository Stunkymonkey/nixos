{ config, lib, pkgs, ... }:
{
  imports = [
    ./fonts.nix
  ];

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
    evince
    firefox
    ghostwriter
    (gimp-with-plugins.override {
      plugins = with gimpPlugins; [
        resynthesizer
      ];
    })
    gnome.adwaita-icon-theme
    gnome.dconf-editor
    gnome.eog
    gnome.file-roller
    keepassxc
    libreoffice
    (mpv.override {
      scripts = with mpvScripts; [
        convert
        mpris
        simple-mpv-webui
        sponsorblock
      ];
    })
    newsflash
    polkit_gnome
    rhythmbox
    tdesktop
    thunderbird
    vlc
    wayvnc
    xdg-utils
    zathura
    zeal

    # terminal
    socat
    sshuttle
    libnotify
    keychain
  ];

  # Enable firmware update daemon
  services.fwupd.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # enable the gui
  };

  # start sway if login happens
  environment.interactiveShellInit = ''
    if test `tty` = /dev/tty1; then
      exec sway
    fi
  '';
}
