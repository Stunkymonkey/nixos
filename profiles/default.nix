# Configuration that spans accross system and home, or are collections of modules
{ ... }:
{
  imports = [
    ./3d-design
    ./android
    ./clean
    ./development
    ./filesystem
    ./gaming
    ./gnome
    ./latex
    ./media
    ./meeting
    ./nautilus
    ./powersave
    ./printing
    ./sway
    ./sync
    ./update
    ./usb-iso
    ./webcam
  ];
}
