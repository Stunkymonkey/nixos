{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    evince
    firefox
    ghostwriter
    (gimp-with-plugins.override {
      plugins = with gimpPlugins; [
        resynthesizer
      ];
    })
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
    rhythmbox
    tdesktop
    thunderbird
    vlc
    wayvnc
    zathura
    zeal
    # terminal
    socat
    sshuttle
    libnotify
    keychain
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # enable the gui
  };
}
