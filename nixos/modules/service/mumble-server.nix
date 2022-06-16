{ config, pkgs, ... }:
{
  services.murmur = {
    enable = true;
    welcometext = "Welcome to the Mumble-Server!";
    #sslKey = "";
    #sslCert = "";
  };
}
