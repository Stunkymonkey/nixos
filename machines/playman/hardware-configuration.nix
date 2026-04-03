{
  pkgs,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  my.hardware = {
    bluetooth.enable = true;
    debug.enable = true;
    drive-monitor = {
      enable = true;
      OnFailureMail = "server@buehler.rocks";
    };
    firmware = {
      enable = true;
      cpuFlavor = "intel";
    };
    graphics = {
      enable = true;
      gpuFlavor = "nvidia";
    };
    keychron.enable = true;
    yubikey.enable = true;
  };
}
