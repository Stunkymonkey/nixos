# enabled profiles
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.profiles = {
    "3d-design".enable = true;
    android.enable = true;
    clean.enable = true;
    gaming.enable = true;
    latex.enable = true;
    meeting.enable = true;
    nautilus.enable = true;
    powersave.enable = true;
    printing.enable = true;
    sway.enable = true;
    sync.enable = true;
  };
}
