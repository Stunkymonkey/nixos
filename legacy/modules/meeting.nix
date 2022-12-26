{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    element-desktop
    mumble
    nheko
    skypeforlinux
    signal-desktop
    teamspeak_client
  ];
}
