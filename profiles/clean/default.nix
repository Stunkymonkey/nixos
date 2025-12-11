{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.clean;
in
{
  options.my.profiles.clean = {
    enable = lib.mkEnableOption "clean profile";
  };

  config = lib.mkIf cfg.enable {
    services.angrr = {
      enable = true;
      timer.enable = true;
    };

    environment.systemPackages = with pkgs; [
      baobab
      dupeguru
      jdupes
      kondo
    ];
  };
}
