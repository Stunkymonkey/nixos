{ config, pkgs, ... }:
{
  services.octoprint = {
    enable = true;
    plugins = plugins: with plugins; [
      costestimation
      displayprogress
      m86motorsoff
      stlviewer
      telegram
      titlestatus
    ];
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];
}
