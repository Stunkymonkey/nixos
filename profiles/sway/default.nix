{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.sway;
in
{
  imports = [
    ./autostart.nix
    ./location.nix
    ./screen-sharing.nix
    ./theme.nix
  ];

  options.my.profiles.sway = with lib; {
    enable = mkEnableOption "sway profile";
  };

  config = lib.mkIf cfg.enable {

    my.profiles = {
      sway-autostart.enable = true;
      sway-location.enable = true;
      sway-screen-sharing.enable = true;
      sway-theme.enable = true;
    };

    environment.systemPackages = with pkgs; [ polkit_gnome ];
    environment.pathsToLink = [ "/libexec" ];

    services.seatd.enable = true;

    programs = {
      foot.enable = true;
      light.enable = true;
      wshowkeys.enable = true;

      sway = {
        enable = true;
        wrapperFeatures = {
          gtk = true;
          base = true;
        };

        extraPackages = with pkgs; [
          brightnessctl
          dmenu
          gammastep
          grim
          i3status-rust
          mako
          slurp
          swayidle
          swaylock
          wdisplays
          wezterm
          wf-recorder
          wl-clipboard
          wofi
          xwayland
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
          export NIXOS_OZONE_WL=1
        '';
      };
    };
  };
}
