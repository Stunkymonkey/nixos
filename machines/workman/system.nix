# enabled system services
_: {
  my.system = {
    avahi.enable = true;
    fonts.enable = true;
    kvm = {
      enable = true;
      cpuFlavor = "amd";
    };
    podman.enable = true;
    spell-check.enable = true;
  };
}
