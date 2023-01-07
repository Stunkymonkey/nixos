{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.thunderbolt;
in
{
  options.my.hardware.thunderbolt = {
    enable = lib.mkEnableOption "thunderbolt configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      thunderbolt
    ];
    services.hardware.bolt.enable = true;
  };
}
