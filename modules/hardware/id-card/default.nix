{ config, lib, ... }:
let
  cfg = config.my.hardware.id-card;
in
{
  options.my.hardware.id-card = with lib; {
    enable = mkEnableOption "german id card authentication";
  };

  config = lib.mkIf cfg.enable {
    programs.ausweisapp = {
      enable = true;
      openFirewall = true;
    };
  };
}
