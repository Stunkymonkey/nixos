{ config, lib, pkgs, ... }:
{
  # enable trash & network-mount
  services.gvfs.enable = true;

  environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
  environment.pathsToLink = [
    "/share/nautilus-python/extensions"
  ];

  services.gnome.glib-networking.enable = true; # network-mount

  # default-programms
  xdg.mime.enable = true;
  xdg.icons.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.nautilus

    ffmpegthumbnailer # thumbnails
    gnome.nautilus-python # enable plugins
    gst_all_1.gst-libav # thumbnails
    nautilus-open-any-terminal # terminal-context-entry
  ];
}
