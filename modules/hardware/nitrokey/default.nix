{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.nitrokey;
in
{
  options.my.hardware.nitrokey = {
    enable = lib.mkEnableOption "nitrokey configuration";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.nitrokey-udev-rules ];
    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
