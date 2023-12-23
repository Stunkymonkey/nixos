_:
let
  cpuFlavor = "intel";
in
{
  # video driver
  boot.initrd.kernelModules = [ "i915" ];

  # Special power management settings for ThinkPads
  services.tlp.enable = true;

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
    graphics.cpuFlavor = cpuFlavor;
    id-card.enable = true;
    keychron.enable = true;
    sound.enable = true;
    thunderbolt.enable = true;
    yubikey.enable = true;
  };
}
