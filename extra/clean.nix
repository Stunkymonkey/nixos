{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    baobab
    dupeguru
    unstable.findimagedupes
    jdupes
    kondo
  ];
}
