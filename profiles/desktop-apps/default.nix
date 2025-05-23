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
  options.my.profiles.desktop-apps = with lib; {
    enable = mkEnableOption "desktop-apps profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      evince
      firefox
      (gimp-with-plugins.override {
        plugins = with gimpPlugins; [
          # resynthesizer # disabled because broken with python3
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
  };
}
