{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nix-prefetch-git
    nix-prefetch-github
    nix-update
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-review
  ];
}
