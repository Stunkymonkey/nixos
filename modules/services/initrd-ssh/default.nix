# The Free Software Media System
{ config, lib, ... }:
let
  cfg = config.my.services.initrd-ssh;
in
{
  options.my.services.initrd-ssh = with lib; {
    enable = mkEnableOption "Enable initrd-ssh service";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.network = {
      enable = true;

      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@workman"
        ];
      };

      postCommands = ''
        echo 'cryptsetup-askpass' >> /root/.profile
      '';
    };
  };
}
