# enabled profiles
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.profiles = {
    android.enable = true;
    clean.enable = true;
    latex.enable = true;
    printing.enable = true;
  };
}
