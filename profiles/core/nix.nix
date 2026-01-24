{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.my.profiles.core.nix;
in
{
  options.my.profiles.core.nix.enable = lib.mkEnableOption "core nix profile";

  config = lib.mkIf cfg.enable {

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
  };
}
