{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.sway-screen-sharing;
in
{
  options.my.profiles.sway-screen-sharing = {
    enable = lib.mkEnableOption "sway-screen-sharing profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ remmina ];

    services.pipewire.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    # for firefox
    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      GTK_USE_PORTAL = "1";
    };
  };
}
