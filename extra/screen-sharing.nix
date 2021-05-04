{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    remmina
    teamviewer
  ];
  imports = [ ./xdg-portal.nix ];

  services.pipewire.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    gtkUsePortal = true;
  };

  # for firefox
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
  };
}
