{ config, pkgs, ... }:
{
  services.octoprint = {
    enable = true;
    plugins = plugins: with plugins; [
      #costestimation
      #displayprogress
      #m86motorsoff
      stlviewer
      #telegram
      #title_status
    ];
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];
}
