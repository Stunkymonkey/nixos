# Deployed services
{ config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  # List services that you want to enable:
  my.services = {
    # RSS provider for websites that do not provide any feeds
    rss-bridge.enable = true;
    # Voice-chat server
    mumble-server.enable = true;
  };
}
