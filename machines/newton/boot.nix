_: {
  boot.loader = {
    timeout = 1;
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };
}
