{ config, lib, ... }:

{
  options.webapps = {
    dashboardCategories = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
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
      });
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
      type = lib.types.attrsOf
        (lib.types.submodule {
          options = {
            dashboard.link = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                Link to webapp
              '';
              example = "http://192.168.1.10:1234";
              default = null;
            };
            dashboard.name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                Application name.
              '';
              example = "App";
              default = null;
            };
            dashboard.category = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                App category tag.
              '';
              example = "app";
              default = null;
            };
            dashboard.icon = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                Font Awesome application icon.
              '';
              example = "rss";
              default = null;
            };
            dashboard.type = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                application type.
              '';
              example = "Ping";
              default = "Ping";
            };
            dashboard.method = lib.mkOption {
              type = lib.types.enum [ "get" "head" ];
              description = ''
                method of request used
              '';
              example = "get";
              default = "head";
            };
          };
        });
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
        lib.forEach cfg.dashboardCategories (cat:
          let
            catApps = lib.sort (a: b: a.dashboard.name < b.dashboard.name) (
              builtins.filter
                (a:
                  a.dashboard.category != null && a.dashboard.category == cat.tag ||
                  a.dashboard.category == null && cat.tag == "misc")
                apps);
          in
          {
            name = cat.name;
            items = lib.forEach catApps (a: {
              name = a.dashboard.name;
              icon = lib.optionalString (a.dashboard.icon != null) "fas fa-${a.dashboard.icon}";
              url = a.dashboard.link;
              target = "_blank";
              type = a.dashboard.type;
              method = a.dashboard.method;
            });
          }
        );
      my.services.blackbox.http_endpoints = lib.mapAttrsToList (_key: value: value.dashboard.link) config.webapps.apps ++ [ "https://${config.networking.domain}/" ];
    };
}
