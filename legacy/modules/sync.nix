{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nextcloud-client
    syncthing
    magic-wormhole
    vdirsyncer
  ];
}
