{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  sound.enable = true;
  #hardware.pulseaudio.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  programs.noisetorch.enable = true;

  environment.systemPackages = with pkgs; [
    unstable.noisetorch
    pavucontrol
    playerctl
    pulseaudio # provide pactl to enable keyboard shortcuts
  ];
}
