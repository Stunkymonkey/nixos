# enabled system services
{ ... }:
{
  my.system = {
    avahi.enable = true;
    fonts.enable = true;
    kvm = {
      enable = true;
      cpuFlavor = "intel";
    };
    podman.enable = true;
  };
}
