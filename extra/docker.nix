{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker
    docker_compose
  ];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
}
