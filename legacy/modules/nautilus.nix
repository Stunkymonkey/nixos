{ config, lib, pkgs, ... }:
{
  # enable trash & network-mount
  services.gvfs.enable = true;

  environment.sessionVariables.NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-3.0";
  environment.pathsToLink = [
    "/share/nautilus-python/extensions"
  ];

  services.gnome.glib-networking.enable = true; # network-mount

  environment.systemPackages = with pkgs; [
    # thumbnails
    ffmpegthumbnailer
    gnome.nautilus
    # enable plugins
    gnome.nautilus-python
    # thumbnails
    gst_all_1.gst-libav
    # default-programms
    shared-mime-info
    # terminal-context-entry
    nautilus-open-any-terminal
  ];
}
