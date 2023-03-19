# Hardware-related modules
{ ... }:

{
  imports = [
    ./bluetooth
    ./debug
    ./firmware
    ./graphics
    ./keychron
    ./nitrokey
    ./sound
    ./thunderbolt
  ];
}
