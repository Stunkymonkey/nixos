{ config, pkgs, ... }:
{
  programs.adb.enable = true;
  environment.systemPackages = with pkgs; [
    scrcpy
  ];
}
