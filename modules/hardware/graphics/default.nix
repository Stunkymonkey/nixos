{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.graphics;
in
{
  options.my.hardware.graphics = with lib; {
    enable = mkEnableOption "graphics configuration";
    cpuFlavor = mkOption {
      type =
        with types;
        nullOr (enum [
          "amd"
          "intel"
        ]);
      default = null;
      example = "intel";
      description = "Which kind of GPU";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        hardware.graphics.enable = true;
      }
      # Intel GPU
      (lib.mkIf (cfg.cpuFlavor == "intel") {
        nixpkgs.config.packageOverrides = pkgs: {
          vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
        };
        hardware.graphics.extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiVdpau
          libvdpau-va-gl
        ];
      })

      (lib.mkIf (cfg.cpuFlavor == "amd") {
        hardware.graphics.extraPackages = with pkgs; [
          amdvlk
        ];
        hardware.graphics.extraPackages32 = with pkgs; [
          driversi686Linux.amdvlk
        ];
      })
    ]
  );
}
