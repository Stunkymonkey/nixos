
{ config, pkgs, ... }:

let 
  xdg-fix = pkgs.writeScriptBin "xdg-fix.sh" ''
    #!${pkgs.bash}/bin/sh
    ${pkgs.systemd}/bin/systemctl --user stop xdg-desktop-portal
    ${pkgs.procps}/bin/pkill xdg-desktop-portal
    ${pkgs.procps}/bin/pkill xdg-desktop-portal-gtk
    ${pkgs.procps}/bin/pkill xdg-desktop-portal-wlr
    ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal -v -r &
    ${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk --replace --verbose &
    ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr -l DEBUG -o eDP-1 &
    
  ''; 

in
{
  environment.systemPackages =  [
    xdg-fix
  ];  
}
