{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    unstable.jabref
    biber
    texlive.combined.scheme-full
    texstudio
  ];
}
