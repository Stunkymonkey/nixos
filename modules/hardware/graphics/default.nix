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
    cpuFlavor = mkOption {
      type = with types; nullOr (enum [ "intel" ]);
      default = null;
      example = "intel";
      description = "Which kind of GPU";
    };
  };

  config = lib.mkMerge [
    # Intel GPU
    (lib.mkIf (cfg.cpuFlavor == "intel") {
      nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      };
      hardware.opengl = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
    })
  ];
}
