# Docker related settings
{ config, inputs, lib, options, pkgs, ... }:
let
  cfg = config.my.system.docker;
in
{
  options.my.system.docker = with lib; {
    enable = mkEnableOption "docker configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];

    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };
}
