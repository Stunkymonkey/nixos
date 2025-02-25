# self-hosted recipe manager
{ config, lib, ... }:
let
  cfg = config.my.services.tandoor-recipes;
  inherit (config.networking) domain;
in
{
  options.my.services.tandoor-recipes = with lib; {
    enable = mkEnableOption "Tandoor Recipes";
  };

  config = lib.mkIf cfg.enable {
    services.tandoor-recipes = {
      enable = true;
    };

    # Proxy to Tandoor-Recipes
    my.services.webserver.virtualHosts = [
      {
        subdomain = "recipes";
        inherit (config.services.tandoor-recipes) port;
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
