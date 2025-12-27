_: {
  networking.networkmanager = {
    enable = true;

    unmanaged = [
      "interface-name:br-*" # docker compose bridges
      "interface-name:docker?" # docker default bridge
      "interface-name:veth*" # docker veth devices
      "interface-name:virbr?" # libvirt default bridge
    ];
  };
}
