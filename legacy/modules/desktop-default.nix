{ config, lib, pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./nautilus.nix
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
    evince
    firefox
    ghostwriter
    (gimp-with-plugins.override {
      plugins = with gimpPlugins; [
        resynthesizer
      ];
    })
    glib
    gnome.adwaita-icon-theme
    gnome.dconf-editor
    gnome.eog
    gnome.file-roller
    gnome.gnome-calendar
    gnome.gnome-system-monitor
    gnome.simple-scan
    keepassxc
    keychain
    libnotify
    libreoffice
    lollypop
    (mpv.override {
      scripts = with mpvScripts; [
        convert
        mpris
        simple-mpv-webui
        sponsorblock
        thumbnail
      ];
    })
    newsflash
    polkit_gnome
    rhythmbox
    socat
    sshuttle
    tdesktop
    thunderbird
    vlc
    wayvnc
    xdg-utils
    zathura
    zeal

    # TODO sort them in different files
    #symlinks
  ];

  # Enable firmware update daemon
  services.fwupd.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.accounts-daemon.enable = true;

  environment.interactiveShellInit = ''
    if test `tty` = /dev/tty1; then
      exec sway
    fi
  '';
}
