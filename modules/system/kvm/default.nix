{ config, lib, pkgs, ... }:
let
  cfg = config.my.system.kvm;
in
{
  options.my.system.kvm = with lib; {
    enable = mkEnableOption "kvm configuration";

    cpuFlavor = mkOption {
      type = with types; nullOr (enum [ "intel" "amd" ]);
      default = null;
      example = "intel";
      description = "Which kind of CPU to activate kernelModules";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      virtualisation.libvirtd.enable = true;

      environment.systemPackages = with pkgs; [
        virtmanager
      ];
    }

    # Intel CPU
    (lib.mkIf (cfg.cpuFlavor == "intel") {
      boot.kernelModules = [
        "kvm-intel"
      ];
    })

    # AMD CPU
    (lib.mkIf (cfg.cpuFlavor == "amd") {
      boot.kernelModules = [
        "kvm-amd"
      ];
    })
  ]);
}
