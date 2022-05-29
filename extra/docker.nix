{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
}
