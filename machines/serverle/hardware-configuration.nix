{ pkgs, ... }:
{
  hardware = {
    raspberry-pi."4".leds = {
      eth.disable = true;
      act.disable = true;
      pwr.disable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
}
