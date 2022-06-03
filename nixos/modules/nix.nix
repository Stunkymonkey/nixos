{ config, lib, pkgs, ... }:
{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  environment.systemPackages = with pkgs; [
    nix-prefetch
    nix-update
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-review
  ];
}
