{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    element-desktop
    mumble
    unstable.nheko
    pidgin
    skypeforlinux
    signal-desktop
    teamspeak_client
  ];
}
