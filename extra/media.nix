{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  yt-dlp = pkgs.yt-dlp.override {
    withAlias = true;
  };
in
{
  environment.systemPackages = with pkgs; [
    audacity
    chromaprint # music-brainz fingerprint
    ffmpeg
    gallery-dl
    graphviz
    handbrake
    image_optim
    imagemagick
    inkscape
    unstable.mat2 # metadata-cleaning
    mediaelch
    mp3splt # splitting mp3 files
    mp3val
    pdfsam-basic # pdf editing
    picard
    projectm
    puddletag # audio tagging
    shotwell
    soundkonverter
    yt-dlp
  ];
}
