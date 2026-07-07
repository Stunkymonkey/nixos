{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.nix;
in
{
  options.my.profiles.nix = {
    enable = lib.mkEnableOption "nix profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix-index
      nix-init
      nix-output-monitor
      nix-prefetch
      nix-update
      nixfmt
      nixpkgs-hammering
      nixpkgs-review
      shh
    ];
  };
}
