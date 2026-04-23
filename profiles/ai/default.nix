{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.ai;
in
{
  options.my.profiles.ai = {
    enable = lib.mkEnableOption "ai tools profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.crush
      unstable.antigravity
    ];
  };
}
