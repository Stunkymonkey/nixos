# Hardware-related modules
{ ... }:
{
  imports = [
    ./action-on-low-power
    ./auto-brightness
    ./bluetooth
    ./debug
    ./drive-monitor
    ./firmware
    ./graphics
    ./id-card
    ./keychron
    ./monitor
    ./sound
    ./thunderbolt
    ./yubikey
  ];
}
