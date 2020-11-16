{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    nix-prefetch-git
  ];
}
