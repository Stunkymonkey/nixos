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
  options.my.profiles.nix = with lib; {
    enable = mkEnableOption "nix profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix-index
      nix-init
      nix-prefetch
      nix-update
      nixfmt-rfc-style
      nixpkgs-hammering
      nixpkgs-review
      shh
    ];
  };
}
