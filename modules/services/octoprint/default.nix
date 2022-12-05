# 3d-printing software
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.octoprint;
in
{
  options.my.services.octoprint = with lib; {
    enable = mkEnableOption "Octoprint Server";

    plugins = mkOption {
      type = types.functionTo (types.listOf types.package);
      default = plugins: [ ];
      defaultText = literalExpression "plugins: []";
      example = literalExpression "plugins: with plugins; [ themeify stlviewer ]";
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
