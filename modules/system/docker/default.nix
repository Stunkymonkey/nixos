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

    services.cadvisor.enable = config.services.prometheus.enable;

    services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "docker";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.cadvisor.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };
    # dashboard untested
    services.grafana.provision = {
      dashboards.settings.providers = [
        {
          name = "Docker";
          options.path = pkgs.grafana-dashboards.cadvisor;
          disableDeletion = true;
        }
      ];
    };
  };
}
