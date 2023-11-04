{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/disk/by-id/usb-Seagate_Expansion_2HC015KJ-0:0";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "encrypted";
                extraOpenArgs = [ "--allow-discards" ];
                passwordFile = "/tmp/disk.key";
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "50G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          data = {
            size = "400G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/data";
            };
          };
          swap = {
            size = "4G";
            content = {
              type = "swap";
              randomEncryption = true;
              resumeDevice = true;
            };
          };
        };
      };
    };
  };
}
