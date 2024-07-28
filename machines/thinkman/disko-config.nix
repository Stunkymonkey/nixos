{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0025385b01410682";
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
                mountOptions = [ "defaults" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "encrypted";
                settings.allowDiscards = true;
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
            size = "100G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          home = {
            size = "450G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
          swap = {
            size = "32G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
        };
      };
    };
  };
}
