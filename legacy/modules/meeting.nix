{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    element-desktop
    mumble
    nheko
    teamspeak_client
  ];
}
