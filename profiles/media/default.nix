{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.media;
in
{
  options.my.profiles.media = with lib; {
    enable = mkEnableOption "media profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      audacity # audio editing
      chromaprint # music-brainz fingerprint
      ffmpeg # general purpose
      gallery-dl # image donwloader
      handbrake # video converter
      image_optim # image compressors
      imagemagick # image converter
      inkscape # vector image editing
      mat2 # metadata-cleaning
      mediaelch # video sorting
      metadata-cleaner # mat2-gui
      mp3gain # audio volume
      mp3splt # splitting mp3 files
      mp3val # audio validation
      pdfgrep # grep in pdfs
      pdfsam-basic # pdf editing
      picard # music tagging
      projectm # visualization of music
      puddletag # audio tagging
      shotwell # photo management
      sonixd # cloud-music-player
      soundkonverter # audio converter
      (yt-dlp.override { withAlias = true; }) # video download
    ];
  };
}
