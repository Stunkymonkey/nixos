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
  options.my.hardware.graphics = {
    enable = lib.mkEnableOption "graphics configuration";
    cpuFlavor = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
        ]
      );
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
          intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
        };
        hardware.graphics.extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      })

      (lib.mkIf (cfg.cpuFlavor == "amd") {
      })
    ]
  );
}
