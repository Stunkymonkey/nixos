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
  options.my.profiles.powersave = {
    enable = lib.mkEnableOption "powersave profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      powertop
      s-tui
    ];

    powerManagement = {
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
      # powertop --auto-tune re-enables USB autosuspend for every device, clobbering the udev rules below. Re-trigger them afterwards.
      powertop.postStart = ''
        ${lib.getExe' pkgs.systemd "udevadm"} trigger -c bind -s usb -a idVendor=3434 -a idProduct=0b31
        ${lib.getExe' pkgs.systemd "udevadm"} trigger -c bind -s usb -a idVendor=3434 -a idProduct=0123
      '';
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
