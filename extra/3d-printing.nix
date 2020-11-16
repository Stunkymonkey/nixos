{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    meshlab
    cura
    openscad
  ];
}
