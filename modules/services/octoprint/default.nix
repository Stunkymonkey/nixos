# 3d-printing software
{ config, lib, ... }:
let
  cfg = config.my.services.octoprint;
in
{
  options.my.services.octoprint = {
    enable = lib.mkEnableOption "Octoprint Server";

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      defaultText = lib.literalExpression "plugins: []";
      example = lib.literalExpression "plugins: with plugins; [ themeify stlviewer ]";
      description = lib.mdDoc "Additional plugins to be used. Available plugins are passed through the plugins input.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.octoprint = {
      enable = true;
      plugins = plugins: with plugins; [
        costestimation
        displayprogress
        m86motorsoff
        stlviewer
        telegram
        titlestatus
      ] ++ cfg.plugins;
    };
    networking.firewall.allowedTCPPorts = [ 5000 ];
  };
}
