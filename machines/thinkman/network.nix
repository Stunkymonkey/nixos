# network settings
{ config, lib, ... }:
{
  # hotfixes for dns settings
  networking.extraHosts = ''
    	192.168.178.60 stunkymonkey.de
    	192.168.178.60 movies.stunkymonkey.de
    	192.168.178.60 series.stunkymonkey.de
  '';
}
