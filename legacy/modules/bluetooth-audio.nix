{ config, lib, pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [
    sony-headphones-client
  ];
}
