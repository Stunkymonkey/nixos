{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
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
  services.dbus.packages = [ pkgs.gnome.dconf ];
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  services.gnome = {
    gnome-keyring.enable = true;
    glib-networking.enable = true; # network-mount
  };
  # enable trash & network-mount
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    adwaita-qt
    arc-icon-theme
    arc-kde-theme
    arc-theme
    evince
    firefox-wayland
    #geary
    ghostwriter
    (gimp-with-plugins.override { plugins = with gimpPlugins; [ resynthesizer ]; })
    glib
    gnome.adwaita-icon-theme
    gnome.dconf-editor
    gnome.eog
    gnome.file-roller
    gnome.gnome-calendar
    gnome.gnome-system-monitor
    gnome.nautilus
    gnome.simple-scan
    keepassxc
    keychain
    konsole
    libnotify
    libreoffice
    lollypop
    unstable.newsflash
    numix-cursor-theme
    numix-icon-theme
    numix-icon-theme-circle
    polkit_gnome
    qgnomeplatform
    rhythmbox
    simple-scan
    #spotify
    socat
    sshuttle
    tdesktop
    thunderbird
    virtmanager
    vlc
    mpv-with-scripts
    wayvnc
    xdg-utils
    zathura
    zeal

    # TODO sort them in different files
    pdfgrep
    physlock
    #symlinks
  ];

  # Enable firmware update daemon
  services.fwupd.enable = true;

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  services.accounts-daemon.enable = true;

  environment.interactiveShellInit = ''
    if test `tty` = /dev/tty1; then
      exec sway
    fi
  '';
}
