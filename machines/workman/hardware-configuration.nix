{
  pkgs,
  ...
}:
let
  cpuFlavor = "amd";
in
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  my.hardware = {
    bluetooth.enable = true;
    debug.enable = true;
    drive-monitor.enable = true;
    firmware = {
      enable = true;
      inherit cpuFlavor;
    };
    graphics = {
      enable = true;
      inherit cpuFlavor;
    };
    id-card.enable = true;
    keychron.enable = true;
    monitor.enable = true;
    sound.enable = true;
    thunderbolt.enable = true;
    yubikey.enable = true;
  };
}
