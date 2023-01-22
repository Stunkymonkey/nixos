{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    biber
    pdfpc
    qtikz
    texlive.combined.scheme-full
    texstudio
  ];
}
