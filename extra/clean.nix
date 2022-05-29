{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    baobab
    dupeguru
    findimagedupes
    jdupes
    kondo
  ];
}
