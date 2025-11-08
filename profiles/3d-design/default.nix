{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles."3d-design";
in
{
  options.my.profiles."3d-design" = {
    enable = lib.mkEnableOption "3d-design profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      meshlab
      openscad-unstable
      prusa-slicer
    ];
  };
}
