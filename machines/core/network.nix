{ ... }:
{
  networking.networkmanager = {
    enable = true;

    unmanaged = [
      "interface-name:br-*" # Ignore docker compose network bridges
      "interface-name:docker?" # Ignore docker default bridge
      "interface-name:veth*" # Ignore docker compose network devices
      "interface-name:virbr?" # Ignore libvirt default bridge
    ];
  };

}
