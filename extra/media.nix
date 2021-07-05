{ config, lib, pkgs, ... }:
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
    puddletag # audio tagging
    mp3splt # splitting mp3 files
    mp3val
    mediaelch
    picard
    projectm
    shotwell
    soundkonverter
    youtube-dl
  ];
}
