{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    croc
    magic-wormhole
    nextcloud-client
    syncthing
    vdirsyncer
  ];
}
