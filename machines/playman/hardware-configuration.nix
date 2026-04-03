{
  pkgs,
  ...
}:
let
  cpuFlavor = "intel";
in
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
      inherit cpuFlavor;
    };
    graphics = {
      enable = true;
      inherit cpuFlavor;
    };
    keychron.enable = true;
    yubikey.enable = true;
  };
}
