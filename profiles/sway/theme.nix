{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.sway-theme;
in
{
  options.my.profiles.sway-theme = with lib; {
    enable = mkEnableOption "sway-theme profile";
  };

  config = lib.mkIf cfg.enable {
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
    qt.platformTheme = "qt5ct";
  };
}
