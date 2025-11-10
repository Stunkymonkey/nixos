# Docker related settings
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.system.docker;
in
{
  options.my.system.docker = {
    enable = lib.mkEnableOption "docker configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];

    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
      liveRestore = false;
    };

    services = {
      cadvisor.enable = config.services.prometheus.enable;

      prometheus = {
        scrapeConfigs = [
          {
            job_name = "docker";
            static_configs = [
              {
                targets = [ "localhost:${toString config.services.cadvisor.port}" ];
                labels = {
                  instance = config.networking.hostName;
                };
              }
            ];
          }
        ];
      };
      # dashboard untested
      grafana.provision = {
        dashboards.settings.providers = [
          {
            name = "Docker";
            options.path = pkgs.grafana-dashboards.cadvisor;
            disableDeletion = true;
          }
        ];
      };
    };
  };
}
