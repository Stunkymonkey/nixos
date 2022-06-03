{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    blobby
    discord
    minecraft
    minetest
    openttd
    superTuxKart
    steam
    SDL
    SDL2
    wine
    winetricks
  ];

  programs.steam.enable = true;

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;
}
