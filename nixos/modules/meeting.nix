{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    element-desktop-wayland
    mumble
    nheko
    skypeforlinux
    signal-desktop
    teamspeak_client
  ];
}
