# The Free Software Media System
{ config, lib, ... }:
let
  cfg = config.my.services.initrd-ssh;
in
{
  options.my.services.initrd-ssh = {
    enable = lib.mkEnableOption "Enable initrd-ssh service";

    interface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "eth0";
      description = "Ethernet interface name shown by 'ip addr'";
      default = null;
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "grub2"
        "systemd"
      ];
      default = "systemd";
      description = "Whether to use GRUB2 or systemd for the initrd SSH server.";
    };

    hostKeys = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      example = [ "/run/secret/ssh_host_ed25519_key" ];
      description = "the host keys to use for the SSH server for initrd.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd = {
      network = {
        enable = true;

        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@workman"
          ];
        };

        postCommands = lib.optionalString (cfg.mode == "grub2") ''
          echo 'cryptsetup-askpass && { echo "Unlock was successful; exiting SSH session"; exit 0; }' >> /root/.profile
        '';
      };

      systemd = lib.optionalAttrs (cfg.mode == "systemd") {
        enable = true;
        network = {
          enable = true;
          networks = lib.optionalAttrs (cfg.interface != null) {
            "10-lan" = {
              matchConfig.Name = cfg.interface;
              networkConfig.DHCP = "yes";
            };
          };
        };
        settings.Manager = {
          # remove default 90 seconds timeout
          DefaultDeviceTimeoutSec = "infinity";
        };
        services.luks-remote-unlock = {
          description = "Prepare for LUKS remote unlock";
          wantedBy = [ "initrd.target" ];
          after = [ "systemd-networkd.service" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            echo 'systemctl default && { echo "Unlock was successful; exiting SSH session"; exit 0; }' >> /var/empty/.profile
          '';
        };
      };
    };
  };
}
