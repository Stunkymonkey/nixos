# Hardware-related modules
{ ... }:
{
  imports = [
    ./bluetooth
    ./debug
    ./drive-monitor
    ./firmware
    ./graphics
    ./id-card
    ./keychron
    ./sound
    ./thunderbolt
    ./yubikey
  ];
}
