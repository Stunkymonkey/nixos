{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    nextcloud-client
    unstable.syncthing
    magic-wormhole
    vdirsyncer
  ];
}
