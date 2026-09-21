# Privacy first PDF toolkit running entirely in the browser
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.pdf-toolkit;
  domain = "pdf.${config.networking.domain}";
in
{
  options.my.services.pdf-toolkit = {
    enable = lib.mkEnableOption "PDF toolkit service";
  };

  config = lib.mkIf cfg.enable {
    services.bentopdf = {
      enable = true;
      inherit domain;
      caddy = {
        enable = true;
        virtualHost.extraConfig = lib.mkAfter ''
          import common
        '';
      };
    };

    webapps.apps.pdf-toolkit = {
      dashboard = {
        name = "PDF";
        category = "app";
        icon = "file-pdf";
        url = "https://${domain}";
      };
    };
  };
}
