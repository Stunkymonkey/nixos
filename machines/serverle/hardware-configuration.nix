{ pkgs, ... }:
{
  hardware = {
    raspberry-pi."4".leds = {
      eth.disable = true;
      act.disable = true;
      pwr.disable = true;
    };
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
}
