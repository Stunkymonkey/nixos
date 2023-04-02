{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.update;
in
{
  options.my.profiles.update = with lib; {
    enable = mkEnableOption "update profile";
  };

  config = lib.mkIf cfg.enable {
    # Enable firmware update daemon
    services.fwupd.enable = true;

    environment.systemPackages = with pkgs; [
      topgrade
    ];
  };
}
