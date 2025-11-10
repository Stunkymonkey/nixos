# miracast related settings
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.system.miracast;
in
{
  options.my.system.miracast = {
    enable = lib.mkEnableOption "miracast configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome-network-displays
    ];

    networking.firewall.allowedTCPPorts = [
      7236
      7250
    ];
    networking.firewall.allowedUDPPorts = [
      7236
      5353
    ];
  };
}
