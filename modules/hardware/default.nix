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
    ./monitor
    ./sound
    ./thunderbolt
    ./yubikey
  ];
}
