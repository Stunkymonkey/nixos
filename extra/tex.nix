{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jabref
    biber
    texlive.combined.scheme-full
    texstudio
  ];
}
