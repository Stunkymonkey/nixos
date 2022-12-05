{ config, lib, pkgs, inputs, ... }:
{
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      unstable.flake = inputs.nixpkgs-unstable;
    };
  };

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
