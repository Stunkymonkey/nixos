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
    mp3gain
    mp3splt # splitting mp3 files
    mp3val
    pdfsam-basic # pdf editing
    picard # music tagging
    projectm # visualization of music
    puddletag # audio tagging
    shotwell # photo management
    soundkonverter
    yt-dlp
  ];
}
