{ config, lib, ... }:

{
  options.webapps = {
    dashboardCategories = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = ''
                Category name.
              '';
              example = "Applications";
            };
            tag = lib.mkOption {
              type = lib.types.str;
              description = ''
                Category tag.
              '';
              example = "app";
            };
          };
        }
      );
      description = ''
        App categories to display on the dashboard.
      '';
      example = [
        {
          name = "Application";
          tag = "app";
        }
      ];
      default = [ ];
    };

    apps = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            dashboard = {
              url = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                description = ''
                  Url to webapp
                '';
                example = "http://192.168.1.10:1234";
                default = null;
              };
              name = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                description = ''
                  Application name.
                '';
                example = "App";
                default = null;
              };
              category = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                description = ''
                  App category tag.
                '';
                example = "app";
                default = null;
              };
              icon = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                description = ''
                  Font Awesome application icon.
                '';
                example = "rss";
                default = null;
              };
              type = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                description = ''
                  application type.
                '';
                example = "Ping";
                default = "Ping";
              };
              method = lib.mkOption {
                type = lib.types.enum [
                  "get"
                  "head"
                ];
                description = ''
                  method of request used
                '';
                example = "get";
                default = "head";
              };
            };
          };
        }
      );
      description = ''
        Defines a web application.
      '';
      default = { };
    };
  };

  config =
    let
      cfg = config.webapps;
    in
    {
      lib.webapps.homerServices =
        let
          apps = builtins.filter (a: a.dashboard.name != null) (lib.attrValues cfg.apps);
        in
        lib.forEach cfg.dashboardCategories (
          cat:
          let
            catApps = lib.sort (a: b: a.dashboard.name < b.dashboard.name) (
              builtins.filter (
                a:
                a.dashboard.category != null && a.dashboard.category == cat.tag
                || a.dashboard.category == null && cat.tag == "misc"
              ) apps
            );
          in
          {
            inherit (cat) name;
            items = lib.forEach catApps (a: {
              inherit (a.dashboard)
                method
                name
                type
                url
                ;
              icon = lib.optionalString (a.dashboard.icon != null) "fas fa-${a.dashboard.icon}";
              target = "_blank";
            });
          }
        );
      my.services.blackbox.http_endpoints =
        lib.mapAttrsToList (_key: value: value.dashboard.url) config.webapps.apps
        ++ [ "https://${config.networking.domain}/" ];
    };
}
