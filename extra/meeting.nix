{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    element-desktop
    mumble
    nheko
    pidgin
    skypeforlinux
    signal-desktop
    teamspeak_client
  ];
}
