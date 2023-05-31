# Podman related settings
{ config, inputs, lib, options, pkgs, ... }:
let
  cfg = config.my.system.podman;
in
{
  options.my.system.podman = with lib; {
    enable = mkEnableOption "podman configuration";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    virtualisation.podman = {
      enable = true;

      # Use fake `docker` command to redirect to `podman`
      # but only if docker is not enabled
      dockerCompat = !config.my.system.docker.enable;

      # Expose a docker-like socket
      dockerSocket.enable = true;

      # Allow DNS resolution in the default network
      defaultNetwork.settings.dns_enabled = true;

      autoPrune.enable = true;
    };
  };
}
