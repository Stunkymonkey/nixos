{ config, lib, pkgs, ... }:
{
  nix.settings = {
    trusted-users = [
      "root"
      "@wheel"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # support auto upgrade with flakes
  system.autoUpgrade.flags = [
    "--update-input"
    "nixpkgs"
    "--commit-lock-file"
  ];

  environment.systemPackages = with pkgs; [
    nix-prefetch
    nix-update
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-review
  ];
}
