# Hardware-related modules
{ ... }:
{
  imports = [
    ./bluetooth
    ./debug
    ./drive-monitor
    ./firmware
    ./graphics
    ./keychron
    ./yubikey
    ./sound
    ./thunderbolt
  ];
}
