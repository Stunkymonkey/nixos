{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    audacity
    chromaprint # music-brainz fingerprint
    ffmpeg
    gallery-dl
    graphviz
    handbrake
    imagemagick
    image_optim
    inkscape
    unstable.puddletag # audio tagging
    mp3val
    #mediaelch
    unstable.mediaelch
    picard
    projectm
    shotwell
    soundkonverter
    youtube-dl
  ];
}
