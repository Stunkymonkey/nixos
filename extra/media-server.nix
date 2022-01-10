{ config, lib, pkgs, ... }:
{
  services = {
    # movie management
    radarr = {
      enable = true;
      openFirewall = true;
    };
    # series management
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    # subtitle management
    bazarr = {
      enable = true;
      openFirewall = true;
    };
    # indexer management
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    # media player
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
