{ config, lib, pkgs, ... }:
let
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
    imagemagick
    image_optim
    inkscape
    puddletag # audio tagging
    mp3splt # splitting mp3 files
    mp3val
    mediaelch
    pdfsam-basic # pdf editing
    picard
    projectm
    shotwell
    soundkonverter
    yt-dlp
  ];
}
