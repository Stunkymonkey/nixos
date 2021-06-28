{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nix-prefetch-git
    nix-prefetch-github
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-review
  ];
}
