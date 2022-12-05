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
    image_optim
    imagemagick
    inkscape
    mat2 # metadata-cleaning
    mediaelch
    mp3gain
    mp3splt # splitting mp3 files
    mp3val
    pdfsam-basic # pdf editing
    picard # music tagging
    projectm # visualization of music
    puddletag # audio tagging
    shotwell # photo management
    sonixd # cloud-music-player
    soundkonverter
    yt-dlp
  ];
}
