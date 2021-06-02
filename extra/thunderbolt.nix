{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    thunderbolt
  ];
  services.hardware.bolt.enable = true;
}
