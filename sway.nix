{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    polkit_gnome
  ];
  environment.pathsToLink = [ "/libexec" ];
  #programs.wshowkeys.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
      base = true;
    };

    extraPackages = with pkgs; [
      alacritty
      brightnessctl
      dmenu
      gammastep
      grim
      unstable.i3status-rust
      mako
      slurp
      swayidle
      swaylock
      wdisplays
      wf-recorder
      wl-clipboard
      wofi
      xwayland
      unstable.wshowkeys
    ];

     
    extraSessionCommands = 
    ''  
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
}
