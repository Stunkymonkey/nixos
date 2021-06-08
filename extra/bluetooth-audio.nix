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
  #hardware.pulseaudio = {
  #  enable = true;
  #  extraModules = [ pkgs.pulseaudio-modules-bt ];
  #  package = pkgs.pulseaudioFull;
  #};
  services.blueman.enable = true;
}
