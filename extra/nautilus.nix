{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  # enable trash & network-mount
  services.gvfs.enable = true;

  environment.sessionVariables.NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-3.0";
  environment.pathsToLink = [
    "/share/nautilus-python/extensions"
  ];

  services.gnome.glib-networking.enable = true; # network-mount

  environment.systemPackages = with pkgs; [
    gnome.nautilus
    gnome.nautilus-python
    shared-mime-info
    unstable.nautilus-open-any-terminal
  ];
}
