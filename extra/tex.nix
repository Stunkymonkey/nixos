{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    biber
    jabref
    qtikz
    texlive.combined.scheme-full
    texstudio
  ];
}
