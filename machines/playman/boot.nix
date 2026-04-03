_: {
  boot = {
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = true;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true; # for a nice password prompt
      verbose = false;
    };
  };
}
