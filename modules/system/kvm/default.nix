{ config, lib, ... }:
let
  cfg = config.my.system.kvm;
in
{
  options.my.system.kvm = {
    enable = lib.mkEnableOption "kvm configuration";

    cpuFlavor = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "intel"
          "amd"
        ]
      );
      default = null;
      example = "intel";
      description = "Which kind of CPU to activate kernelModules";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        virtualisation.libvirtd.enable = true;

        programs.virt-manager.enable = true;
      }

      # Intel CPU
      (lib.mkIf (cfg.cpuFlavor == "intel") { boot.kernelModules = [ "kvm-intel" ]; })

      # AMD CPU
      (lib.mkIf (cfg.cpuFlavor == "amd") { boot.kernelModules = [ "kvm-amd" ]; })
    ]
  );
}
