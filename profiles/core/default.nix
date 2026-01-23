{
  config,
  lib,
  ...
}:
let
  cfg = config.my.profiles.core;
in
{
  imports = [
    ./kernel-modules.nix
    ./network.nix
    ./nix.nix
    ./packages.nix
    ./users.nix
  ];

  options.my.profiles.core.enable = lib.mkEnableOption "core profile";

  config = lib.mkIf cfg.enable {
    my.profiles.core = {
      packages.enable = lib.mkDefault true;
      kernel-modules.enable = lib.mkDefault true;
      network.enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
      users.enable = lib.mkDefault true;
    };

    time.timeZone = "Europe/Berlin";
  };
}
