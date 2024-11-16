{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.nautilus;
in
{
  options.my.profiles.nautilus = with lib; {
    enable = mkEnableOption "nautilus profile";
  };

  config = lib.mkIf cfg.enable {
    # make sure gnome parts are there for storing settings
    my.profiles.gnome.enable = true;

    # enable trash & network-mount
    services.gvfs.enable = true;

    services.gnome.glib-networking.enable = true; # network-mount

    # default-programs
    xdg.mime.enable = true;
    xdg.icons.enable = true;

    environment = {
      systemPackages = with pkgs; [
        nautilus

        ffmpegthumbnailer # thumbnails
        nautilus-python # enable plugins
        gst_all_1.gst-libav # thumbnails
        nautilus-open-any-terminal # terminal-context-entry
      ];

      sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
      pathsToLink = [ "/share/nautilus-python/extensions" ];
    };

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "foot";
    };
  };
}
