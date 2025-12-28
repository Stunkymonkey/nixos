{
  pkgs,
  ...
}:
{
  boot = {
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "max"; # needed for plymouth
        editor = true;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true; # for a nice password prompt
      verbose = false;
    };
    # Enable "Silent boot"
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    plymouth = {
      enable = true;
      theme = "framework";
      themePackages = [ pkgs.framework-plymouth ];
    };
  };
}
