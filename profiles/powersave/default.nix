{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.powersave;
in
{
  options.my.profiles.powersave = with lib; {
    enable = mkEnableOption "powersave profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      powertop
      s-tui
    ];

    powerManagement = {
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
    };

    services = {
      thermald.enable = true;
      upower.enable = true;
    };

    services.udev.extraRules = ''
      # disable USB auto suspend for Keychron Q3 HE
      ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="3434", ATTR{idProduct}=="0b31", ATTR{power/autosuspend}="-1"
      # disable USB auto suspend for Keychron Q3
      ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="3434", ATTR{idProduct}=="0123", ATTR{power/autosuspend}="-1"
    '';
  };
}
