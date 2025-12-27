{
  config,
  lib,
  pkgs,
  inputs,
  ...
}@args:
let
  cfg = config.my.profiles.core;
in
{
  options.my.profiles.core.enable = lib.mkEnableOption "core profile";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (import ./core.nix args)
      (import ./modules.nix args)
      (import ./network.nix args)
      (import ./nix.nix args)
      (import ./users.nix args)
    ]
  );
}
