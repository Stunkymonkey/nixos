{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.sway;
in
{
  imports = [
    ./location.nix
    ./screen-sharing.nix
    ./theme.nix
  ];

  options.my.profiles.sway = with lib; {
    enable = mkEnableOption "sway profile";
  };

  config = lib.mkIf cfg.enable {

    my.profiles = {
      sway-location.enable = true;
      sway-screen-sharing.enable = true;
      sway-theme.enable = true;
    };

    environment.systemPackages = with pkgs; [
      polkit_gnome
    ];
    environment.pathsToLink = [ "/libexec" ];

    programs.wshowkeys.enable = true;
    programs.light.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures = {
        gtk = true;
        base = true;
      };

      extraPackages = with pkgs; [
        brightnessctl
        dmenu
        foot
        gammastep
        grim
        i3status-rust
        mako
        slurp
        swayidle
        swaylock
        wdisplays
        wf-recorder
        wl-clipboard
        wofi
        xwayland
        # wshowkeys
      ];

      extraSessionCommands = ''
        export XDG_SESSION_TYPE=wayland
        export XDG_CURRENT_DESKTOP=sway
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export CLUTTER_BACKEND=wayland
        export SAL_USE_VCLPLUGIN=gtk3
        export MOZ_ENABLE_WAYLAND=1
        export MOZ_USE_XINPUT2=1
      '';
    };
  };
}