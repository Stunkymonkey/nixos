# self-hosted recipe manager
{ config, lib, ... }:
let
  cfg = config.my.services.tandoor-recipes;
  domain = config.networking.domain;
in
{
  options.my.services.tandoor-recipes = with lib; {
    enable = mkEnableOption "Tandoor Recipes";
    port = mkOption {
      type = types.port;
      default = 8089;
      example = 8080;
      description = "Internal port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tandoor-recipes = {
      enable = true;
      port = cfg.port;
    };

    # Proxy to Tandoor-Recipes
    my.services.nginx.virtualHosts = [
      {
        subdomain = "recipes";
        inherit (cfg) port;
      }
    ];

    webapps.apps.tandoor-recipes = {
      dashboard = {
        name = "Recipes";
        category = "app";
        icon = "utensils";
        link = "https://recipes.${domain}";
      };
    };
  };
}
