{
  config,
  lib,
  ...
}:
let
  cfg = config.my.hardware.yubikey;
in
{
  options.my.hardware.yubikey = {
    enable = lib.mkEnableOption "yubikey configuration";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      yubikey-manager.enable = true;
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
