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

  # test if working
  #xdg.mime.enable = true;

  # make gnome settings persistent
  
  programs.dconf.enable = true;

  # gnome services
  services.dbus.packages = [ pkgs.gnome3.dconf ];
  services.udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];
  services.gnome3.gnome-keyring.enable = true;
  services.gnome3.glib-networking.enable = true;
  # enable trash & network-mount in nautilus
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    #mime-types
    xdg_utils
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
    gnome3.adwaita-icon-theme
    gnome3.eog
    gnome3.file-roller
    gnome3.gnome-calendar
    gnome3.gnome-system-monitor
    gnome3.nautilus
    gnome3.nautilus-python
    gnome3.simple-scan
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
    tdesktop
    thunderbird
    typora
    virtmanager
    vlc
    mpv-with-scripts
    wayvnc
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

#  services.xserver = {
#    enable = true;
#    layout = "us";
#    xkbOptions = "eurosign:e";
#    libinput.enable = true;
#    libinput.naturalScrolling = true;
#
#    startDbusSession = true;
#    updateDbusEnvironment = true;
#
#    desktopManager = {
#      xterm.enable = false;
#      gnome3.enable = false;
#    };
#
#    displayManager = {
#      sessionData.sessionNames = [ "sway" "none+i3" ];
#      defaultSession = "sway";
#      gdm.enable = true;
#      gdm.wayland = true;
#      lightdm.enable = false;
#    };
#  };
}
