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
    ./nitrokey
    ./sound
    ./thunderbolt
  ];
}
