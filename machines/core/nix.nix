{ pkgs, inputs, ... }:
{
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
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

  # auto upgrade with own flakes
  system.autoUpgrade = {
    enable = true;
    flake = "github:Stunkymonkey/nixos";
  };

  environment.systemPackages = with pkgs; [
    nix-index
    nix-prefetch
    nix-update
    nixfmt-rfc-style
    nixpkgs-hammering
    nixpkgs-review
  ];
}
