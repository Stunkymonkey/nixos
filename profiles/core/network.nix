{ config, lib, ... }:
let
  cfg = config.my.profiles.core.network;
in
{
  options.my.profiles.core.network.enable = lib.mkEnableOption "core network profile";

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;

      unmanaged = [
        "interface-name:br-*" # docker compose bridges
        "interface-name:docker?" # docker default bridge
        "interface-name:veth*" # docker veth devices
        "interface-name:virbr?" # libvirt default bridge
      ];
    };
  };
}
