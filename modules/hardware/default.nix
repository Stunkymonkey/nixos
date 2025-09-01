# Hardware-related modules
{ ... }:
{
  imports = [
    ./action-on-low-power
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
