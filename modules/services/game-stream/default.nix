{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.game-stream;
in
{
  options.my.services.game-stream = {
    enable = lib.mkEnableOption "game-streaming-server";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sunshine
    ];
    services.udev.packages = [ pkgs.sunshine ];
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        {
          from = 8000;
          to = 8010;
        }
      ];
    };
    # Prevents this error:
    # Fatal: You must run [sudo setcap cap_sys_admin+p $(readlink -f sunshine)] for KMS display capture to work!
    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };
  };
}
