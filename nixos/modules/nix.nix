{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nix-prefetch
    nix-update
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-review
  ];
}
