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
    gpuFlavor = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
          "nvidia"
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
      (lib.mkIf (cfg.gpuFlavor == "intel") {
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

      (lib.mkIf (cfg.gpuFlavor == "amd") {
      })
      (lib.mkIf (cfg.gpuFlavor == "nvidia") {
      })
    ]
  );
}
