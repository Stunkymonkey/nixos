{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    biber
    qtikz
    texlive.combined.scheme-full
    texstudio
  ];
}
