{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.clean;
in
{
  options.my.profiles.clean = with lib; {
    enable = mkEnableOption "clean profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      baobab
      dupeguru
      findimagedupes
      jdupes
      kondo
    ];
  };
}
