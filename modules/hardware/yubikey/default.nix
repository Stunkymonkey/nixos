{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.yubikey;
in
{
  options.my.hardware.yubikey = {
    enable = lib.mkEnableOption "yubikey configuration";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.yubikey-personalization ];
    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      yubikey-manager
    ];
  };
}
