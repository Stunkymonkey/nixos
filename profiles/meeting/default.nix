{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.meeting;
in
{
  options.my.profiles.meeting = with lib; {
    enable = mkEnableOption "meeting profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # TODO revert fix: https://github.com/NixOS/nixpkgs/issues/238416
      (element-desktop.override { electron = pkgs.electron_24; })
      mumble
      nheko
      teamspeak_client
    ];
  };
}
