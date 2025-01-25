# self-hosted recipe manager
{ config, lib, ... }:
let
  cfg = config.my.services.tandoor-recipes;
  inherit (config.networking) domain;
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
      inherit (cfg) port;
    };

    # Proxy to Tandoor-Recipes
    my.services.webserver.virtualHosts = [
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
        url = "https://recipes.${domain}";
      };
    };
  };
}
