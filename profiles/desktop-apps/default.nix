{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.desktop-apps;
in
{
  options.my.profiles.desktop-apps = {
    enable = lib.mkEnableOption "desktop-apps profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firefox
      (gimp-with-plugins.override {
        plugins = with gimpPlugins; [
          resynthesizer
        ];
      })
      kdePackages.ghostwriter
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
      papers
      rhythmbox
      telegram-desktop
      thunderbird
      vlc
      zathura
      zeal
      # terminal
      socat
      sshuttle
      libnotify
      keychain
    ];

    programs = {
      wayvnc.enable = true;
      wireshark = {
        enable = true;
        package = pkgs.wireshark; # enable the gui
      };

    };
  };
}
