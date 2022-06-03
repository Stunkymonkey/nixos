{ config, lib, pkgs, ... }:

{
  boot = {
    loader = {
      timeout = 1;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "keep";
        editor = true;
      };
    };
  };
}
