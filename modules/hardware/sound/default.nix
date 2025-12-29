{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.sound;
in
{
  options.my.hardware.sound = {
    enable = lib.mkEnableOption "sound configuration with pipewire";
  };

  config = lib.mkIf cfg.enable {

    # RealtimeKit is recommended
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      pulse.enable = true;

      jack.enable = true;
    };

    programs.noisetorch.enable = true;

    environment.systemPackages = with pkgs; [
      noisetorch
      playerctl
      pwvucontrol
    ];
  };
}
