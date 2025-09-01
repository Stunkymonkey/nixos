_:
let
  cpuFlavor = "intel";
in
{
  # video driver
  boot.initrd.kernelModules = [ "i915" ];

  # fix audio
  boot.extraModprobeConfig = ''
    options snd-hda-intel dmic_detect=0
  '';

  # Special power management settings for ThinkPads
  services.tlp.enable = true;

  my.hardware = {
    action-on-low-power.enable = true;
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
