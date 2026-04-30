{
  pkgs,
  lib,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.useDHCP = lib.mkForce true;

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
